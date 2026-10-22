class irq_coverage extends uvm_component;

    `uvm_component_utils(irq_coverage)

    int unsigned source_id;
    int unsigned priority;
    int unsigned threshold;

    bit irq_asserted;
    bit claim_seen;
    bit complete_seen;

    covergroup irq_cg;

        cp_source: coverpoint source_id {
            bins source_ids[] = {[1:16]};
        }

        cp_priority: coverpoint priority {
            bins disabled = {0};
            bins low      = {[1:2]};
            bins medium   = {[3:5]};
            bins high     = {[6:7]};
        }

        cp_threshold: coverpoint threshold {
            bins threshold_values[] = {[0:7]};
        }

        cp_irq: coverpoint irq_asserted;
        cp_claim: coverpoint claim_seen;
        cp_complete: coverpoint complete_seen;

        priority_threshold_cross:
            cross cp_priority, cp_threshold;

    endgroup

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);
        irq_cg = new();
    endfunction

    function void sample_event(
        int unsigned src,
        int unsigned prio,
        int unsigned thresh,
        bit irq_value,
        bit claimed,
        bit completed
    );

        source_id = src;
        priority = prio;
        threshold = thresh;
        irq_asserted = irq_value;
        claim_seen = claimed;
        complete_seen = completed;

        irq_cg.sample();

    endfunction

endclass
