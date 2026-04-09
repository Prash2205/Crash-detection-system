module PowerBackup(
    input clk, reset,
    input crash_detected
);
    reg power_hold;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            power_hold <= 0;
        end else if (crash_detected) begin
            power_hold <= 1; // Activate power backup system
        end
    end
endmodule