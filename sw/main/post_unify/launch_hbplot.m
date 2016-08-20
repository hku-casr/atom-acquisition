f = fopen('plot1');
tmp = fscanf(f,'%x');
vals = double(typecast(uint8(tmp),'int8'));
adcvals=-vals(1:100*344);
adcvals16b=vec2mat(adcvals,16);

[loff,imgB] = hbplot(adcvals16b,338.839475);
