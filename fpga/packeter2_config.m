
function packet_filter_config(this_block)

  % Revision History:
  %
  %   11-Dec-2014  (16:42 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     /opt/hk4/untouched/packer_files/packeter2.v
  %
  %

  this_block.setTopLevelLanguage('Verilog');

  this_block.setEntityName('packet_filter');

  % System Generator has to assume that your entity  has a combinational feed through; 
  %   if it  doesn't, then comment out the following line:
  this_block.tagAsCombinational;

  this_block.addSimulinkInport('reset');
  this_block.addSimulinkInport('fifo_empty');
  this_block.addSimulinkInport('data_in');
  this_block.addSimulinkInport('payload_len');
  this_block.addSimulinkInport('period');
  this_block.addSimulinkInport('ready');

  this_block.addSimulinkOutport('fifo_rd');
  this_block.addSimulinkOutport('dout');
  this_block.addSimulinkOutport('valid');
  this_block.addSimulinkOutport('eof');

  fifo_rd_port = this_block.port('fifo_rd');
  fifo_rd_port.setType('UFix_1_0');
  fifo_rd_port.useHDLVector(false);
  dout_port = this_block.port('dout');
  dout_port.setType('UFix_64_0');
  valid_port = this_block.port('valid');
  valid_port.setType('UFix_1_0');
  valid_port.useHDLVector(false);
  eof_port = this_block.port('eof');
  eof_port.setType('UFix_1_0');
  eof_port.useHDLVector(false);

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('reset').width ~= 1);
      this_block.setError('Input data type for port "reset" must have width=1.');
    end

    this_block.port('reset').useHDLVector(false);

    if (this_block.port('fifo_empty').width ~= 1);
      this_block.setError('Input data type for port "fifo_empty" must have width=1.');
    end

    this_block.port('fifo_empty').useHDLVector(false);

    if (this_block.port('data_in').width ~= 64);
      this_block.setError('Input data type for port "data_in" must have width=64.');
    end

    if (this_block.port('payload_len').width ~= 14);
      this_block.setError('Input data type for port "payload_len" must have width=14.');
    end

    if (this_block.port('period').width ~= 14);
      this_block.setError('Input data type for port "period" must have width=14.');
    end

    if (this_block.port('ready').width ~= 1);
      this_block.setError('Input data type for port "ready" must have width=1.');
    end

    this_block.port('ready').useHDLVector(false);

  end  % if(inputTypesKnown)
  % -----------------------------

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk','ce')
   end  % if(inputRatesKnown)
  % -----------------------------

    % (!) Set the inout port rate to be the same as the first input 
    %     rate. Change the following code if this is untrue.
    uniqueInputRates = unique(this_block.getInputRates);

  % (!) Custimize the following generic settings as appropriate. If any settings depend
  %      on input types, make the settings in the "inputTypesKnown" code block.
  %      The addGeneric function takes  3 parameters, generic name, type and constant value.
  %      Supported types are boolean, real, integer and string.
  this_block.addGeneric('AMBER_TIME','integer','10');

  % Add addtional source files as needed.
  %  |-------------
  %  | Add files in the order in which they should be compiled.
  %  | If two files "a.vhd" and "b.vhd" contain the entities
  %  | entity_a and entity_b, and entity_a contains a
  %  | component of type entity_b, the correct sequence of
  %  | addFile() calls would be:
  %  |    this_block.addFile('b.vhd');
  %  |    this_block.addFile('a.vhd');
  %  |-------------

  %    this_block.addFile('');
  %    this_block.addFile('');
  this_block.addFile('packer_files/packeter2.v');

return;


% ------------------------------------------------------------

function setup_as_single_rate(block,clkname,cename) 
  inputRates = block.inputRates; 
  uniqueInputRates = unique(inputRates); 
  if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) 
    block.addError('The inputs to this block cannot all be constant.'); 
    return; 
  end 
  if (uniqueInputRates(end) == Inf) 
     hasConstantInput = true; 
     uniqueInputRates = uniqueInputRates(1:end-1); 
  end 
  if (length(uniqueInputRates) ~= 1) 
    block.addError('The inputs to this block must run at a single rate.'); 
    return; 
  end 
  theInputRate = uniqueInputRates(1); 
  for i = 1:block.numSimulinkOutports 
     block.outport(i).setRate(theInputRate); 
  end 
  block.addClkCEPair(clkname,cename,theInputRate); 
  return; 

% ------------------------------------------------------------

