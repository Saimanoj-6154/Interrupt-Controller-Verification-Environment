class irq_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(irq_virtual_sequencer)

    intr_src_sequencer src_seqr;

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

endclass
