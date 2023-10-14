module mmu
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- MMU->Mem 接続 (物理アドレス) ----- */
        // 命令
        output wire         MEM_INST_RDEN,
        output wire [31:0]  MEM_INST_RIADDR,
        input wire  [31:0]  MEM_INST_ROADDR,
        input wire          MEM_INST_RVALID,
        input wire  [31:0]  MEM_INST_RDATA,

        // データ
        output wire         MEM_DATA_RDEN,
        output wire [31:0]  MEM_DATA_RIADDR,
        input wire  [31:0]  MEM_DATA_ROADDR,
        input wire          MEM_DATA_RVALID,
        input wire  [31:0]  MEM_DATA_RDATA,
        output wire         MEM_DATA_WREN,
        output wire [3:0]   MEM_DATA_WSTRB,
        output wire [31:0]  MEM_DATA_WADDR,
        output wire [31:0]  MEM_DATA_WDATA,

        // ハザード
        input wire          MEM_WAIT,

        /* ----- Core->MMU 接続 (物理アドレス or 仮想アドレス) ----- */
        // 命令
        input wire          MAIN_INST_RDEN,
        input wire  [31:0]  MAIN_INST_RIADDR,
        output wire [31:0]  MAIN_INST_ROADDR,
        output wire         MAIN_INST_RVALID,
        output wire [31:0]  MAIN_INST_RDATA,

        // データ
        input wire          MAIN_DATA_RDEN,
        input wire  [31:0]  MAIN_DATA_RIADDR,
        output wire [31:0]  MAIN_DATA_ROADDR,
        output wire         MAIN_DATA_RVALID,
        output wire [31:0]  MAIN_DATA_RDATA,
        input wire          MAIN_DATA_WREN,
        input wire  [3:0]   MAIN_DATA_WSTRB,
        input wire  [31:0]  MAIN_DATA_WADDR,
        input wire  [31:0]  MAIN_DATA_WDATA,

        // ハザード
        output wire         MMU_WAIT
    );

    assign MEM_INST_RDEN    = MAIN_INST_RDEN;
    assign MEM_INST_RIADDR  = MAIN_INST_RIADDR;
    assign MAIN_INST_ROADDR = MEM_INST_ROADDR;
    assign MAIN_INST_RVALID = MEM_INST_RVALID;
    assign MAIN_INST_RDATA  = MEM_INST_RDATA;

    assign MEM_DATA_RDEN    = MAIN_DATA_RDEN;
    assign MEM_DATA_RIADDR  = MAIN_DATA_RIADDR;
    assign MAIN_DATA_ROADDR = MEM_DATA_ROADDR;
    assign MAIN_DATA_RVALID = MEM_DATA_RVALID;
    assign MAIN_DATA_RDATA  = MEM_DATA_RDATA;
    assign MEM_DATA_WREN    = MAIN_DATA_WREN;
    assign MEM_DATA_WSTRB   = MAIN_DATA_WSTRB;
    assign MEM_DATA_WADDR   = MAIN_DATA_WADDR;
    assign MEM_DATA_WDATA   = MAIN_DATA_WDATA;

    assign MMU_WAIT         = MEM_WAIT;

endmodule
