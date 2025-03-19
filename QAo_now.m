function Q=QAo_now(t, T, TS, TMAX, QMAX) %input time and output Q
%filename: QAo_now.m
tc=rem(t,T); % tc = time elapsed since 
%the beginning of the current cycle
%rem(t,T) is the remainder when t is divided by T
if(tc<TS) %if time elapsed is smaller than duration of systole
  %SYSTOLE:
  if(tc<TMAX) %if time elapsed is smaller than time at which flow is max
    %BEFORE TIME OF MAXIMUM FLOW:
    Q=QMAX*tc/TMAX; %calculate Q
  else
    %AFTER TIME OF PEAK FLOW:
    Q=QMAX*(TS-tc)/(TS-TMAX); %calculate Q
  end
else
  %DIASTOLE:
  Q=0;
end
end
