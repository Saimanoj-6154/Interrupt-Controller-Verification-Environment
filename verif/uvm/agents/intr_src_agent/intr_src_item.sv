class intr_src_item extends uvm_sequence_item;

    rand int unsigned source_id;
    rand bit level;
    rand int unsigned hold_cycles;

    constraint legal_source {
        source_id inside {[0:15]};
    }

    constraint legal_duration {
        hold_cycles inside {[1:20]};
    }

    `uvm_object_utils_begin(intr_src_item)
        `uvm_field_int(source_id, UVM_ALL_ON)
        `uvm_field_int(level, UVM_ALL_ON)
        `uvm_field_int(hold_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "intr_src_item");
        super.new(name);
    endfunction

endclass
