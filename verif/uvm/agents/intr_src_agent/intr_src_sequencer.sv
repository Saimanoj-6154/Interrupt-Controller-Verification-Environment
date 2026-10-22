class intr_src_sequencer
    extends uvm_sequencer #(intr_src_item);

    `uvm_component_utils(intr_src_sequencer)

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

endclass
