function [lineoffset, img, numObjs, objs] = hbplot(adcvals16b,P)
% Process ADC data from ROACH.
% This is a full streaming version of hbplot.m.  Supposedly it should go
% directly into Simulink design.
%
% Returns @lineoffset a column vector describing how much offset each line presents
%  @img the image matrix

% The period @P is not necesarily integer.  So scan line has to be formed
% with a bit of hack
%
% data input are in 16 byte blocks, just like the one on ROACH
periodResample = floor(P);
% The magic number P for our 4GSPS experiment seems to be around 344.403135

numObjs = 0;
objs(1,:)=[0 0 0 0];


%% Quick hack to center the channel info
% by finding one like in threshold, and then skipping periodResample - 1 blocks
startBlk = 1;
while (startBlk < length(adcvals16b))
    b = adcvals16b(startBlk,:);
    th = 10;
    b_th = bsxfun(@gt,b,th);
    if (sum(b_th) > 5)
        startBlk = startBlk + floor(periodResample / 2);
        break;
    end
    startBlk = startBlk + 1;
end
startBlk = max(startBlk - 5,0);
fprintf('Start block at %d\n', startBlk);

%% Resample input into lines.
% Each line will contain b_per_line 16 data blocks.  But since
% periodResample is not necessarily a multiple of 16, there will be
% misaligned blocks at the end.  To handle that, the remaining data of a
% line is dropped.  Also, the fractional ratio between signal period and
% resample preriod will be handled here using similar logic as method 4 in
% hplot.m.
blk_per_line = floor(periodResample / 16);

% The following is mimicking the work of a pipelined hardware
% Each cycle: 1 new block from input (blk)
% Depending on the previous line, blk has to be shifted by an amount blksft
% The input blk is connected to 2 sets of ping-poing block registers.
% (Ping-pong of a ping-pong) A+B, and C+D
% Start with A+B, 
% Even number of block blk is shifted by blksft and write to TAIL of B and HEAD
% of A.  Then on next cycle (odd blk), blk is written to TAIL of A and HEAD of
% B.
% At the end of line, the blk is written to TAIL of (A or B), and also
% shifted by a new amount (the new blksft for next line) and write to HEAD of
% C.

% index adcvals16b.  In hw, it will be shifted in.  
%idxblk=1;
idxblk = startBlk;

imgline=1; % index to output image.  In hw, it will simple be shifted out

blksft = 0; % first line block shift = 0
pp_prev = zeros(1,16);
pp_cur = zeros(1,16);
pp_nextcur = zeros(1,16);
blkgap = false;
pre=0; % for fraction calc.  Needed in hw.
numLineSinceLastHack = 0;
while (idxblk + blk_per_line < length(adcvals16b))
    %fprintf('Processig line %d\n', imgline);
    %
    % Begin each line
    %
    % HHH: Hack alert!  We'll never be able to get the exact value of P.
    % As a result, the image will always drift given enough image lines.
    % So hack here:  Let's reset all sub-sample and sub-block alignment
    % after 20000 lines
    if (numLineSinceLastHack > 20000)
        pre=0;
        numLineSinceLastHack = 0;
        disp('Reseting alignment after 20000 lines');
    else
        numLineSinceLastHack = numLineSinceLastHack + 1;
    end
    
    lineoffset(imgline,1) = pre;
    
    % Calculate  block shift of next line, taking into account fractional period of input signal
    % This should be done early in the line even in hardware so that it is
    % ready by the time we reach the end of this line
    % Standard next_blksft
    next_blksft = blksft + (periodResample - (16 * blk_per_line));
    post = P - pre - periodResample;
    if (post > 0)
        % skip 1 more
        next_blksft = next_blksft + 1;
        pre = 1 - post;
    else
        % no need to skip
        pre = - post;
    end
    
    % have extra breathing space
    % e.g. gap of 5, block 16, then next_blkgap if next_blksft = 12, ... 16
    %next_blkgap = (next_blksft > (16 - (periodResample - (16 * blk_per_line))) || blksft == 0);
    next_blkgap = (next_blksft > 16 || blksft == 0);
    next_blksft = mod(next_blksft, 16);
    
    % The following code are mimicking the work of hardware
    blk_offset = 0; % reset blk_offset idx into each block of 1 line, HW counter
    while (blk_offset < blk_per_line)
        blk = adcvals16b(idxblk,:);
        idxblk = idxblk + 1;
        
        pp_nextcur(1:end-next_blksft) = blk(next_blksft+1:end);
        
        % During blkgap, no need to write to output img.  Also, imgline doesn't
        % increase as no new blk is output.
        if (blkgap)
            %fprintf('Processig block gap!\n');
            pp_cur(1:end-blksft) = blk(blksft+1:end);
            pp_prev = zeros(1,16);
            blkgap = false;
        else
            % normal blocks
            if (blksft == 0) % special case, mostly at beginning, or if no fraction
                pp_cur = zeros(1,16);
                pp_prev = blk;
            else
                pp_cur(1:end-blksft) = blk(blksft+1:end);
                pp_prev(end-blksft+1:end) = blk(1:blksft);
            end
            % At this point, each _prev is done, and the _{,next}cur has the
            % HEAD already filled with some materials.
            % In hardware, we probably need another cycle before writing to
            % img
            img(imgline,(blk_offset * 16 + 1):(blk_offset * 16 + 16)) = pp_prev;

            blk_offset = blk_offset + 1;
        end % end if (blkgap)
        % Last block needs to point to pp_nextcur instead
        if (blk_offset == blk_per_line)
            pp_prev = pp_nextcur;
        else
            pp_prev = pp_cur;
        end
    end % end foreach blk_offset

    % update for next line.
    imgline = imgline + 1;
    blksft = next_blksft;
    blkgap = next_blkgap;
end %end of all blocks

% imagesc(img);
% colormap(gray);
% r= img;
% return;

%% Background Removal
% Remove background from the image.
%
% Method 1:
% On matlab, the simplest way is to
% subtract mean (or median) from each column to reduce noise
% imgsub = bsxfun(@minus,img, median(img));

% Method 2:
% On hardware, use an average of 8 sampled lines
bg = img(1,:);
for i=2:7
    bg = bg + img(i,:);
end
bg = bg / 8;
imgsub = bsxfun(@minus,img, bg);

%% Detect start/stop of droplet
thresholdY = 2000;
thresholdX = 12;
thresholdDetHys = 5;
% Method 1: simple thresholding on abserror
detstate = 0;
dethys = 0;
objIdx = 1;
numAvgline=16;
% a lineval is simply the sum of abs of all pixles in 1 line
curlinevals(1:length(imgsub(:,1)))= 0;
smalinevals(1:length(imgsub(:,1)))=0;
imgoverlay = repmat(-1,size(imgsub));
linevalwindow(1:5) = 0;
for i=1:numAvgline
    linevalwindow(i) = sumabs(imgsub(i,:));
end
bglineval = mean(linevalwindow);
smalineval = bglineval;
maxline = zeros(size(imgsub(1,:)));
for i=(numAvgline+1):length(imgsub(:,1))
    smalinevals(i) = smalineval;  % record to plot
    curlineval= sumabs(imgsub(i,:));
    curlinevals(i) = curlineval;  % record it to plot
    % update window
    linevalwindow = [linevalwindow(2:end) curlineval];
    nextsmalineval = mean(linevalwindow);

    if (detstate == 0) % in empty space
        %            if (abs(nextsmalineval - bglineval) > 100) %assume it is something interesting
        if (nextsmalineval > thresholdY && nextsmalineval > smalineval) %hack alert: threshold
            dethys = dethys + 1;
        else
            dethys = max(0,dethys - 1);
        end
        if (dethys > thresholdDetHys)
            fprintf('Change state to 1 at line %d\n',i);
            detstate = 1;
            dethys = 0;
            objBegin = i;
        end
    elseif (detstate == 1) % seen 1st begin cell wall, in droplet
%            if (abs(nextsmalineval - bglineval) < 10)
        if (nextsmalineval > thresholdY && nextsmalineval < smalineval)
            dethys = dethys + 1;
        else
            dethys = max(0,dethys - 1);
        end
        if (dethys > thresholdDetHys)
            fprintf('Change state to 2 at line %d\n',i);
            detstate = 2;
            dethys = 0;
        end
    elseif (detstate == 2) % seen 1st end cell wall, in droplet
            % if (abs(nextsmalineval - bglineval) > 100) %assume it is something interesting
        if (nextsmalineval > thresholdY && nextsmalineval > smalineval) %hack alert: threshold
            dethys = dethys + 1;
        else
            dethys = max(0,dethys - 1);
        end
        if (dethys > thresholdDetHys)
            fprintf('Change state to 3 at line %d\n',i);
            detstate = 3;
            dethys = 0;
        end
    elseif (detstate == 3) % see 2nd begin cell well
        if (nextsmalineval > thresholdY && nextsmalineval < smalineval) %hack alert: threshold
            dethys = dethys + 1;
        else
            dethys = max(0,dethys - 1);
        end
        if (dethys > thresholdDetHys)
            fprintf('Change state to 0 at line %d\n',i);
            detstate = 0;
            dethys = 0;
            objEnd = i;
            %figure(1);
            %plot(maxline);
            % find objLeft, objRight
            maxline_th = maxline > thresholdX; % hack alert: threshold
            objLeft = find(maxline_th, 1, 'first');
            objRight = find(maxline_th, 1, 'last');
            objs(objIdx,:) = [objBegin objLeft objRight objEnd];
            objIdx = objIdx + 1;
        end
        % HHH: Detect Left/Right BB of obj while inside droplet as well.
        maxline = bsxfun(@max, abs(imgsub(i,:)), maxline);
        objLeft = 0;
        objRight = periodResample;
    end
    
    % imgoverlay(i,:) = detstate;
    % update window
    smalineval = nextsmalineval;
end


%% Display
% First convert original data into RGB data (so I can draw overlay later)
colormap(gray);
minV = min(min(imgsub));
maxV = max(max(imgsub));
rangeV = maxV - minV;
thismap = colormap();
maxcol = size(thismap, 1) - 1;
scaledimg = uint8(floor((imgsub - minV) ./ rangeV .* maxcol));
imgrgb = ind2rgb(scaledimg, gray);
%figure();
%image(imgrgb);
title('Captured image in RGB');

if (objIdx - 1 >= 1)
    numObjs = size(objs,1);
    fprintf('Found %d Objects!\n', size(objs,1));

    %Draw them directly on imgsub;
    for objIdx=1:size(objs,1)
        dim = objs(objIdx,:);
        imgrgb(dim(1),dim(2):dim(3),:) = repmat([0 1 0], dim(3)-dim(2)+1, 1);
        imgrgb(dim(4),dim(2):dim(3),:) = repmat([0 1 0], dim(3)-dim(2)+1, 1);
        imgrgb(dim(1):dim(4),dim(2),:) = repmat([0 1 0], dim(4)-dim(1)+1, 1);
        imgrgb(dim(1):dim(4),dim(3),:) = repmat([0 1 0], dim(4)-dim(1)+1, 1);

        % The below code is suppose to enlarge the bounding box.  But it's
        % quite buggy.  Let's not bother with it for now (HS)
%         c = [floor((dim(2) + dim(3)) / 2), floor((dim(1) + dim(4)) /2)];
%         imgrgb(c(2) - 256,c(1)-8:c(1)+7,:) = repmat([0 1 0], 16, 1);
%         imgrgb(c(2) + 255,c(1)-8:c(1)+7,:) = repmat([0 1 0], 16, 1);
%         imgrgb(c(2)-256:c(2)+255,c(1)-8,:) = repmat([0 1 0], 512, 1);
%         imgrgb(c(2)-256:c(2)+255,c(1)+7,:) = repmat([0 1 0], 512, 1);
    end
else
    disp('No object found!');
    numObjs = 0;
end

figure(1);
plot(1:length(curlinevals),curlinevals,'r',1:length(smalinevals),smalinevals,'b',1:length(smalinevals),bglineval,'g');
title('curlinevals + smalinevals');

figure(2);
%imB = imagesc(imgsub);
image(imgrgb);
%colormap(gray);
title(sprintf('Image with Detected Objects (P=%d)',P));
% hold on
% imF = imagesc(imgoverlay);
% alpha(imF,0.2)
% hold off

%figure;
%imagesc(imgoverlay);
%colormap(hot);
%imshow(mat2gray(img));
%title(sprintf('Overlay (P=%d)',P));

end
