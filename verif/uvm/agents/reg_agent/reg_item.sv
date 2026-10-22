class reg_item extends uvm_sequence_item;

    rand bit write;
    rand bit [15:0] addr;
    rand bit [31:0] wdata;

    bit [31:0] rdata;
    bit [1:0] target;

    `uvm_object_utils_begin(reg_item)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(target, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "reg_item");
        super.new(name);
    endfunction

endclass
