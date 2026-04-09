module SensorFIFO(
    input clk, reset,
    input [15:0] accel_x, accel_y, accel_z,
    input [15:0] gyro_x, gyro_y, gyro_z,
    input [15:0] pressure,
    output reg [15:0] fifo_accel_x, fifo_accel_y, fifo_accel_z,
    output reg [15:0] fifo_gyro_x, fifo_gyro_y, fifo_gyro_z,
    output reg [15:0] fifo_pressure
);

    // FIFO depth (number of data samples)
    parameter FIFO_DEPTH = 8;

    // Internal registers to store FIFO data
    reg [15:0] accel_x_fifo [0:FIFO_DEPTH-1];
    reg [15:0] accel_y_fifo [0:FIFO_DEPTH-1];
    reg [15:0] accel_z_fifo [0:FIFO_DEPTH-1];
    reg [15:0] gyro_x_fifo [0:FIFO_DEPTH-1];
    reg [15:0] gyro_y_fifo [0:FIFO_DEPTH-1];
    reg [15:0] gyro_z_fifo [0:FIFO_DEPTH-1];
    reg [15:0] pressure_fifo [0:FIFO_DEPTH-1];

    // Write pointer for FIFO
    integer write_ptr = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
        end else begin
            // Store sensor data in FIFO
            accel_x_fifo[write_ptr] <= accel_x;
            accel_y_fifo[write_ptr] <= accel_y;
            accel_z_fifo[write_ptr] <= accel_z;
            gyro_x_fifo[write_ptr] <= gyro_x;
            gyro_y_fifo[write_ptr] <= gyro_y;
            gyro_z_fifo[write_ptr] <= gyro_z;
            pressure_fifo[write_ptr] <= pressure;

            // Increment write pointer, wrap around if needed
            write_ptr <= (write_ptr + 1) % FIFO_DEPTH;
        end
    end

    // Output the last data in FIFO using procedural assignments
    always @(*) begin
        fifo_accel_x = accel_x_fifo[write_ptr - 1];
        fifo_accel_y = accel_y_fifo[write_ptr - 1];
        fifo_accel_z = accel_z_fifo[write_ptr - 1];
        fifo_gyro_x = gyro_x_fifo[write_ptr - 1];
        fifo_gyro_y = gyro_y_fifo[write_ptr - 1];
        fifo_gyro_z = gyro_z_fifo[write_ptr - 1];
        fifo_pressure = pressure_fifo[write_ptr - 1];
    end

endmodule

