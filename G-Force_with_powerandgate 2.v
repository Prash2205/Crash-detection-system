`timescale 1ns / 1ps

module CrashDetection(
    input clk, reset,
    input [15:0] accel_x, accel_y, accel_z,
    input [15:0] gyro_x, gyro_y, gyro_z,
    input [15:0] pressure,
    output reg crash_detected,
    output reg alert_signal,
    output reg [15:0] crash_log // Define crash_log as a single bus (16 bits wide)
);

// Parameters for states
parameter IDLE = 2'b00, MONITOR = 2'b01, CRASH_DETECTED = 2'b10;
parameter ACCEL_THRESHOLD = 16'h2000;
parameter GYRO_THRESHOLD = 16'h1800;
parameter PRESSURE_THRESHOLD = 16'h1000;
parameter G_FORCE_THRESHOLD = 16'h4000;

// FIFO Buffer Outputs for Sensor Data
wire [15:0] fifo_accel_x, fifo_accel_y, fifo_accel_z;
wire [15:0] fifo_gyro_x, fifo_gyro_y, fifo_gyro_z;
wire [15:0] fifo_pressure;

// G-Force Calculation (magnitude of acceleration)
wire [31:0] ax2, ay2, az2, g_force;
assign ax2 = fifo_accel_x * fifo_accel_x;
assign ay2 = fifo_accel_y * fifo_accel_y;
assign az2 = fifo_accel_z * fifo_accel_z;
assign g_force = ax2 + ay2 + az2; // Approximate sqrt by skipping the root operation

// FSM for crash detection
reg [1:0] current_state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        crash_detected <= 0;
        alert_signal <= 0;
    end else begin
        current_state <= next_state;
        
        // Ensure crash_detected and alert_signal are only set in sequential logic
        if (current_state == CRASH_DETECTED) begin
            crash_detected <= 1;
            alert_signal <= 1;
        end else begin
            crash_detected <= 0;
            alert_signal <= 0;
        end
    end
end

// Next state logic remains unchanged
always @(*) begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (|fifo_accel_x || |fifo_accel_y || |fifo_accel_z || 
                |fifo_gyro_x || |fifo_gyro_y || |fifo_gyro_z || |fifo_pressure)
                next_state = MONITOR;
        end
        MONITOR: begin
            if ((fifo_accel_x > ACCEL_THRESHOLD || fifo_accel_y > ACCEL_THRESHOLD || fifo_accel_z > ACCEL_THRESHOLD) ||
                (fifo_gyro_x > GYRO_THRESHOLD || fifo_gyro_y > GYRO_THRESHOLD || fifo_gyro_z > GYRO_THRESHOLD) ||
                (fifo_pressure > PRESSURE_THRESHOLD) || (g_force > G_FORCE_THRESHOLD)) begin
                next_state = CRASH_DETECTED;
            end
        end
        CRASH_DETECTED: begin
            next_state = IDLE;
        end
    endcase
end

// FIFO Buffer Instance (Assuming a FIFO module is defined elsewhere)
SensorFIFO sensor_fifo (
    .clk(clk),
    .reset(reset),
    .accel_x(accel_x), .accel_y(accel_y), .accel_z(accel_z),
    .gyro_x(gyro_x), .gyro_y(gyro_y), .gyro_z(gyro_z),
    .pressure(pressure),
    .fifo_accel_x(fifo_accel_x), .fifo_accel_y(fifo_accel_y), .fifo_accel_z(fifo_accel_z),
    .fifo_gyro_x(fifo_gyro_x), .fifo_gyro_y(fifo_gyro_y), .fifo_gyro_z(fifo_gyro_z),
    .fifo_pressure(fifo_pressure)
);

// Power Backup Module Instance
PowerBackup power_backup (
    .clk(clk),
    .reset(reset),
    .crash_detected(crash_detected)
);

// Clock Gating Module Instance
wire gated_clk;
ClockGating clock_gating (
    .clk(clk),
    .enable(crash_detected),
    .gated_clk(gated_clk)
);

endmodule