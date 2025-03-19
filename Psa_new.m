function Psa=Psa_new(Psa_old,QAo,Rs,Csa,dt) %input last Psa and Qao, output new Psa
%filename:   Psa_new.m
Psa=(Psa_old+dt*QAo/Csa)/(1+dt/(Rs*Csa)); %calculate Psa
end