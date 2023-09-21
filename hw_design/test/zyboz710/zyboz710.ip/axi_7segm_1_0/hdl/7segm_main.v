module segm7_main #
    (
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        parameter integer C_S_AXI_ADDR_WIDTH    = 16
    )
    (
        // 回路接続
        output reg                              COM_SER,
        output reg                              COM_RCLK,
        output reg                              COM_SRCLK,
        output reg                              SEG_SER,
        output reg                              SEG_RCLK,
        output reg                              SEG_SRCLK,

        // AXIバス
        input wire                              S_AXI_ACLK,
        input wire                              S_AXI_ARSTN,
        input wire  [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_AWADDR,
        input wire                              S_AXI_AWVALID,
        input wire  [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_WDATA,
        input wire                              S_AXI_WVALID,
        input wire  [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_ARADDR,
        output wire [C_S_AXI_DATA_WIDTH-1:0]    reg_data_out
    );

    assign reg_data_out = slv_reg1;

    /* ----- AXIバス ==> 接続回路 ----- */
    // 書き込みチェック信号
    assign slv_reg_wren = S_AXI_WVALID && S_AXI_AWVALID;

    // SLVレジスタ書き込み
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARSTN == 1'b0) begin
            slv_reg1 <= 32'b0;
        end
        else begin
            if (slv_reg_wren) begin
                case (S_AXI_AWADDR)
                    16'h0000: slv_reg1 <= S_AXI_WDATA;
                endcase
            end
        end
    end

    /* ----- 分周(1/4) ----- */
    reg [1:0] clk_cnt;

    assign clk = clk_cnt == 2'b0;

    always @ (posedge S_AXI_ACLK) begin
        if (!S_AXI_ARSTN)
            clk_cnt <= 2'b0;
        else
            clk_cnt <= clk_cnt + 2'b1;
    end

    /* ----- 接続回路への出力 ----- */
    // 制御用ステートマシン
    parameter S_CTL_IDLE  = 2'b00;
    parameter S_CTL_WRITE = 2'b01;

    reg [1:0]  ctl_state, next_ctl_state;
    reg        send_en;
    reg [7:0]  ctl_com_data;
    reg [31:0] ctl_seg_data;

    always @ (posedge clk) begin
        if (!S_AXI_ARSTN)
            ctl_state <= S_CTL_IDLE;
        else
            ctl_state <= next_ctl_state;
    end

    always @* begin
        case (ctl_state)
            S_CTL_IDLE:
                next_ctl_state <= S_CTL_WRITE;

            S_CTL_WRITE:
                if (COM_RCLK && ctl_com_data[6] == 1'b0)
                    next_ctl_state <= S_CTL_IDLE;
                else
                    next_ctl_state <= S_CTL_WRITE;

            default:
                next_ctl_state <= S_CTL_IDLE;
        endcase
    end

    always @ (posedge clk) begin
        if (ctl_state == S_CTL_IDLE) begin
            send_en <= 1'b1;
            ctl_com_data <= 8'b11111101;
            ctl_seg_data <= slv_reg1;
        end
        else if (ctl_state == S_CTL_WRITE && COM_RCLK) begin
            send_en <= ctl_com_data[6] != 1'b0;
            ctl_com_data <= { ctl_com_data[6:0], 1'b1 };
            ctl_seg_data <= { 4'b0, ctl_seg_data[31:4] };
        end
        else
            send_en <= 1'b0;
    end

    // COM,SEG用ステートマシン
    parameter S_CS_IDLE   = 2'b00;
    parameter S_CS_SEND   = 2'b01;
    parameter S_CS_WAIT   = 2'b11;
    parameter S_CS_FINISH = 2'b10;

    reg [1:0] cs_state, next_cs_state;
    reg [2:0] cs_cnt;
    reg [7:0] com_data, seg_data;

    always @ (posedge clk) begin
        if (!S_AXI_ARSTN)
            cs_state <= S_CS_IDLE;
        else
            cs_state <= next_cs_state;
    end

    always @* begin
        case (cs_state)
            S_CS_IDLE:
                if (send_en)
                    next_cs_state <= S_CS_SEND;
                else
                    next_cs_state <= S_CS_IDLE;

            S_CS_SEND:
                next_cs_state <= S_CS_WAIT;

            S_CS_WAIT:
                if (cs_cnt == 3'b0)
                    next_cs_state <= S_CS_FINISH;
                else
                    next_cs_state <= S_CS_SEND;

            S_CS_FINISH:
                next_cs_state <= S_CS_IDLE;

            default:
                next_cs_state <= S_CS_IDLE;
        endcase
    end

    always @ (posedge clk) begin
        if (cs_state == S_CS_IDLE) begin
            cs_cnt <= 3'b0;

            com_data <= ctl_com_data;
            COM_RCLK <= 1'b0;
            COM_SRCLK <= 1'b0;

            seg_data <= gen_7seg(ctl_seg_data[3:0]);
            SEG_RCLK <= 1'b0;
            SEG_SRCLK <= 1'b0;
        end
        else if (cs_state == S_CS_SEND) begin
            cs_cnt <= cs_cnt + 3'b1;

            COM_SER <= com_data[cs_cnt];
            COM_SRCLK <= 1'b1;

            SEG_SER <= seg_data[cs_cnt];
            SEG_SRCLK <= 1'b1;
        end
        else if (cs_state == S_CS_WAIT) begin
            COM_SRCLK <= 1'b0;

            SEG_SRCLK <= 1'b0;
            SEG_RCLK <= cs_cnt == 3'b0;
        end
        else if (cs_state == S_CS_FINISH) begin
            COM_RCLK <= 1'b1;
        end
    end

    function [7:0] gen_7seg;
        input [3:0] VALUE;

        case (VALUE)
            4'h0: gen_7seg = 8'b01111110;
            4'h1: gen_7seg = 8'b00110000;
            4'h2: gen_7seg = 8'b01101101;
            4'h3: gen_7seg = 8'b01111001;
            4'h4: gen_7seg = 8'b00110011;
            4'h5: gen_7seg = 8'b01011011;
            4'h6: gen_7seg = 8'b01011111;
            4'h7: gen_7seg = 8'b01110010;
            4'h8: gen_7seg = 8'b01111111;
            4'h9: gen_7seg = 8'b01111011;
            4'ha: gen_7seg = 8'b01110111;
            4'hb: gen_7seg = 8'b00011111;
            4'hc: gen_7seg = 8'b01001110;
            4'hd: gen_7seg = 8'b00111101;
            4'he: gen_7seg = 8'b01001111;
            4'hf: gen_7seg = 8'b01000111;
        endcase
    endfunction

endmodule
