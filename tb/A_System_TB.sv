`timescale 1ns/1ps

module tb_SYS_TOP;

    //========================================================
    // Parameters
    //========================================================

    localparam int PRESCALE = 32;
    localparam realtime REF_HALF_PERIOD  = 10.0;
    localparam realtime UART_HALF_PERIOD = 135.63368;

    logic UART_RX_IN;
    logic UART_CLK;
    logic REF_CLK;
    logic RST_N;

    logic UART_TX_O;

    logic parity_error;
    logic framing_error;

    SYS_TOP DUT (
        .UART_RX_IN   (UART_RX_IN),
        .UART_CLK     (UART_CLK),
        .REF_CLK      (REF_CLK),
        .RST_N        (RST_N),

        .UART_TX_O    (UART_TX_O),
        .parity_error (parity_error),
        .framing_error(framing_error)
    );

    always #(REF_HALF_PERIOD)
    REF_CLK = ~REF_CLK;

    always #(UART_HALF_PERIOD)
    UART_CLK = ~UART_CLK;

    //========================================================
    // SystemVerilog struct
    //========================================================

    typedef struct {
        logic [7:0] data;
        time        start_time;
    } tx_item_t;

    tx_item_t tx_queue[$];  //SystemVerilog With Variable Width

    //========================================================
    // Parity Function
    // PAR_TYP = 0 --> Even Parity
    //========================================================

    function automatic logic even_parity(
        input logic [7:0] data
    );

        return ^data;

    endfunction

    //========================================================
    // Parity Function
    // PAR_TYP = 1 --> Odd Parity
    //========================================================

    function automatic logic odd_parity(
        input logic [7:0] data
    );

        return (~(^data));

    endfunction


    //========================================================
    // Drive one UART bit
    //========================================================

    task automatic drive_uart_bit(
        input logic bit_value
    );

        int PRESCALE_NOW = DUT.UART_Config[7:2];

        @(negedge DUT.UART_RX_CLK);

        UART_RX_IN = bit_value;

        repeat (PRESCALE_NOW)
            @(posedge DUT.UART_RX_CLK);

    endtask


    //========================================================
    // Send one complete UART Frame
    //========================================================

    task automatic uart_send_byte(
        input logic [7:0] data
    );

        logic parity_bit;
        if (DUT.UART_Config[0]) begin

            if (DUT.UART_Config[1]) begin
                parity_bit = odd_parity(data);
            end
            else begin
                parity_bit = even_parity(data);
            end

        end

        $display("[%0t] UART RX Send = 0x%02h",
                 $time, data);


        // Start bit
        drive_uart_bit(1'b0);


        // Data bits -> LSB First
        for (int i = 0; i < 8; i++) begin

            drive_uart_bit(data[i]);

        end

        // Parity bit -> If Parity_Enable == 1
        if (DUT.UART_Config[0]) begin
            drive_uart_bit(parity_bit);
        end

        // Stop bit
        drive_uart_bit(1'b1);

        repeat (2)
            @(posedge UART_CLK);

    endtask


    //========================================================
    // UART TX Monitor
    //========================================================

    task automatic uart_tx_monitor();

        tx_item_t item;
        logic parity_bit;

        forever begin

            // Wait UART_TX_O_V, (Busy)
            @(posedge DUT.UART_TX_O_V);

            item.start_time = $time;
            item.data       = '0;

            #1ps;


            //START Bit must be 0
            assert (UART_TX_O === 1'b0)
            else
                $error("[%0t] UART Start Bit Error", $time);

            //------------------------------------------------
            // Read 8 data bits
            //------------------------------------------------

            for (int i = 0; i < 8; i++) begin

                @(posedge DUT.UART_TX_CLK);

                #1ps;

                item.data[i] = UART_TX_O;

            end

            //------------------------------------------------
            // Read parity
            //------------------------------------------------

            if (DUT.UART_Config[0]) begin

            @(posedge DUT.UART_TX_CLK);
            #1ps;
            parity_bit = UART_TX_O;
            assert (parity_bit === even_parity(item.data))
            else
                $error(
                    "[%0t] TX Parity Error: Data = 0x%02h",
                    $time,
                    item.data
                );

            end
            //------------------------------------------------
            // Read Stop bit
            //------------------------------------------------

            @(posedge DUT.UART_TX_CLK);

            #1ps;

            assert (UART_TX_O === 1'b1)
            else
                $error("[%0t] UART Stop Bit Error", $time);

            //------------------------------------------------
            // Put received byte in queue
            //------------------------------------------------

            tx_queue.push_back(item);

            $display(
                "[%0t] UART TX Captured = 0x%02h",
                $time,
                item.data
            );

        end

    endtask


    //========================================================
    // Expect a TX response
    //========================================================

    task automatic expect_tx_byte(

        input logic [7:0] expected,
        input time        command_done_time,
        input time        timeout = 2ms

    );

        tx_item_t item;
        bit response_received;
        response_received = 1'b0;


        fork : WAIT_FOR_RESPONSE

            begin

                wait (tx_queue.size() > 0);

                item = tx_queue.pop_front();

                response_received = 1'b1;

            end

            begin

                #(timeout);

            end

        join_any

        disable WAIT_FOR_RESPONSE;

        assert (response_received)
        else begin

            $fatal(
                1,
                "[%0t] TIMEOUT: No UART response received",
                $time
            );

        end


        //--------------------------------------------
        // Check actual data
        //--------------------------------------------

        assert (item.data === expected)

            $display(
                "\nPASS: Expected = 0x%02h, Received = 0x%02h\nResponse started after %0t\n",
                expected,
                item.data,
                item.start_time - command_done_time
            );

        else

            $fatal(
                1,
                "\nFAIL: Expected = 0x%02h, Received = 0x%02h\n",
                expected,
                item.data
            );

    endtask

    //----------------------------------------------------
    // RX frame error checks
    //----------------------------------------------------

    task automatic frame_error_checks(arguments);

        assert (
            parity_error  === 1'b0 &&
            framing_error === 1'b0
        )
        else
            $fatal(
                1,
                "UART RX Error: parity=%b framing=%b",
                parity_error,
                framing_error
            );

    endtask


    //========================================================
    // Main Test
    //========================================================

    initial begin

        time command_done_time;

        REF_CLK    = 1'b0;
        UART_CLK   = 1'b0;
        UART_RX_IN = 1'b1;
        RST_N      = 1'b0;

        fork
            uart_tx_monitor();
        join_none


        //----------------------------------------------------
        // Reset
        //----------------------------------------------------

        repeat (5)
            @(posedge REF_CLK);

        repeat (5)
            @(posedge UART_CLK);

        RST_N = 1'b1;

        wait (
            DUT.SYNC_SYS_RST  === 1'b1 &&
            DUT.SYNC_UART_RST === 1'b1
        );

        $display(
            "\n[%0t] Reset released and synchronized\n",
            $time
        );

        //----------------------------------------------------
        // Register File Read command
        //----------------------------------------------------

        uart_send_byte(8'hBB);
        uart_send_byte(8'h02);

        command_done_time = $time;

        expect_tx_byte(
            8'h81,
            command_done_time
        );

        //----------------------------------------------------
        // Register File Write command
        //----------------------------------------------------

        uart_send_byte(8'hAA);
        uart_send_byte(8'h09);
        uart_send_byte(8'h3A);

        //----------------------------------------------------
        // Register File Read What I Write
        //----------------------------------------------------

        uart_send_byte(8'hBB);
        uart_send_byte(8'h09);

        command_done_time = $time;

        expect_tx_byte(
            8'h3A,
            command_done_time
        );

        //----------------------------------------------------
        //  ALU Operation command with operand
        //----------------------------------------------------

        uart_send_byte(8'hCC);
        uart_send_byte(8'h4B);
        uart_send_byte(8'h3A);
        uart_send_byte(8'h02);

        expect_tx_byte(
            8'h10,
            command_done_time
        );
        expect_tx_byte(
            8'hFE,
            command_done_time
        );

        //----------------------------------------------------
        //  Register File Write command
        //  ***** Write in REG[0] Are Forbidden
        //----------------------------------------------------

        uart_send_byte(8'hAA);
        uart_send_byte(8'h00);
        uart_send_byte(8'hAB);

        //----------------------------------------------------
        //  Register File Write command
        //  ***** Write in REG[1] Are Forbidden
        //----------------------------------------------------

        uart_send_byte(8'hAA);
        uart_send_byte(8'h01);
        uart_send_byte(8'h9D);

        //----------------------------------------------------
        //  ALU Operation command with No operand
        //  The Same Operands (A,B) Of ALU Operation command with operand
        //----------------------------------------------------

        uart_send_byte(8'hDD);
        uart_send_byte(8'h04);

        expect_tx_byte(
            8'h00,
            command_done_time
        );
        expect_tx_byte(
            8'h0A,
            command_done_time
        );

        //----------------------------------------------------
        //  Register File Write command
        //  ***** Write in REG[2] & Change The Prescale,Parity_EN AND Parity_Type
        //  Prescale = 16 , Parity_EN = 0
        //----------------------------------------------------

        uart_send_byte(8'hAA);
        uart_send_byte(8'h02);
        uart_send_byte(8'h42);

        //----------------------------------------------------
        //  ALU Operation command with No operand
        //  The Same Operands (A,B) Of ALU Operation command with operand
        //----------------------------------------------------

        uart_send_byte(8'hDD);
        uart_send_byte(8'h00);

        expect_tx_byte(
            8'h00,
            command_done_time
        );
        expect_tx_byte(
            8'h85,
            command_done_time
        );



        $display(
            "\n===================================="
        );

        $display(
            "      TEST PASSED"
        );

        $display(
            "====================================\n"
        );


        #10us;

        $stop;

    end


endmodule
