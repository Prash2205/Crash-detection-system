`timescale 1ns / 1ps

module tb_CrashDetection;

    // Define inputs
    reg clk, reset;
    reg [15:0] accel_x, accel_y, accel_z;
    reg [15:0] gyro_x, gyro_y, gyro_z;
    reg [15:0] pressure;

    // Define outputs
    wire crash_detected;
    wire alert_signal;

    // Instantiate the Unit Under Test (UUT)
    CrashDetection uut (
        .clk(clk),
        .reset(reset),
        .accel_x(accel_x),
        .accel_y(accel_y),
        .accel_z(accel_z),
        .gyro_x(gyro_x),
        .gyro_y(gyro_y),
        .gyro_z(gyro_z),
        .pressure(pressure),
        .crash_detected(crash_detected),
        .alert_signal(alert_signal)
    );

    // Generate clock
    always #5 clk = ~clk;

    // Stimulus Task with enhanced randomization
    task apply_stimulus(input [15:0] ax, ay, az, gx, gy, gz, pr);
        begin
            accel_x = ax;
            accel_y = ay;
            accel_z = az;
            gyro_x = gx;
            gyro_y = gy;
            gyro_z = gz;
            pressure = pr;
            #10;
        end
    endtask

    // Testbench Execution
    initial begin
        $dumpfile("crash_detection.vcd");
        $dumpvars(0, tb_CrashDetection);
        clk = 0;
        reset = 1;
        #10 reset = 0;

        // Apply different test cases with varied randomness
        repeat (50) begin
            apply_stimulus($random % 16'hFFFF, $random % 16'hFFFF, $random % 16'hFFFF, 
                           $random % 16'hFFFF, $random % 16'hFFFF, $random % 16'hFFFF, 
                           $random % 16'hFFFF);
        end

        // Edge cases (e.g., transition from normal to high impact)
        apply_stimulus(16'h0500, 16'h0500, 16'h0500, 16'h0500, 16'h0500, 16'h0500, 16'h0500);
        apply_stimulus(16'h8000, 16'h8000, 16'h8000, 16'h8000, 16'h8000, 16'h8000, 16'h8000);
        
        // Extend simulation to allow FSM transitions
        #2000;
        $finish;
    end

endmodule