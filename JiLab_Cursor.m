
  function   [CURSOR, BMI_Data] = JiLab_Cursor(BMI_Data,Im,frame_idx)
  % Cursor for Ji Lab experiments

  % WAL3's cursor for the BMI experiments

  % d02.28.2020
  % WAL3
dsample_fact = 1;

  if BMI_Data.BMIready ==1; % if BMI is ready to go:

      % standard BMI, Index into E1-E4;
      Im = imresize(single(round(Im)),1/dsample_fact); % convert from 16bit
      BMI_Data.ROI_val(1,frame_idx) = mean(mean(Im(round(BMI_Data.ROI.coordinates{1}(:,2)/dsample_fact),round(BMI_Data.ROI.coordinates{1}(:,1)/dsample_fact)),1));
      BMI_Data.ROI_val(2,frame_idx) = mean(mean(Im(round(BMI_Data.ROI.coordinates{2}(:,2)/dsample_fact),round(BMI_Data.ROI.coordinates{2}(:,1)/dsample_fact)),1));
      BMI_Data.ROI_val(3,frame_idx) = mean(mean(Im(round(BMI_Data.ROI.coordinates{3}(:,2)/dsample_fact),round(BMI_Data.ROI.coordinates{3}(:,1)/dsample_fact)),1));
      BMI_Data.ROI_val(4,frame_idx) = mean(mean(Im(round(BMI_Data.ROI.coordinates{4}(:,2)/dsample_fact),round(BMI_Data.ROI.coordinates{4}(:,1)/dsample_fact)),1));
      %BMI_Data.ROI_val(1,frame_idx)
      
      if frame_idx >10;
          for i = 1:4
              baseline(i,:) = prctile(BMI_Data.ROI_val(i,1:end),5)+0.1; % if addaptive, change 99 to 'end'
          end

          for i = 1:4; % TO DO: why does the index start ar 2??
              ROI_dff(i,:) = (BMI_Data.ROI_val(i,1:end)-baseline(i,:))./baseline(i,:)*100;
              % normalize
              ROI_norm(i,:) = (ROI_dff(i,:) - mean(ROI_dff(i,:)))/std(ROI_dff(i,:));
          end

          % Calculate Cursor
          BMI_Data.cursor(:,frame_idx) = ROI_norm(1,frame_idx)+ROI_norm(2,frame_idx) - (ROI_norm(3,frame_idx)+ROI_norm(4,frame_idx));

          % Smooth cursor
          if frame_idx>3;
              rn = 3; % running average...
              CURSOR = (mean(BMI_Data.cursor(:,frame_idx-rn:frame_idx)));
          else % dont smooth cursor if not enough frames...
              CURSOR = ((BMI_Data.cursor(:,frame_idx)));
          end

          BMI_Data.cursor_smoothed(:,frame_idx) = CURSOR;

          BMI_Data.CURSOR = CURSOR;
          CURSOR  % Print cursor value
          BMI_Data.ROI_norm = ROI_norm;
      end
  end
