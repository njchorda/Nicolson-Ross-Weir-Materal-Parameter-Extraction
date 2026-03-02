%NRW Algorithm from page 112 in https://nvlpubs.nist.gov/nistpubs/Legacy/TN/nbstechnicalnote1536.pdf
clear;clc;close all
c0 = physconst('lightspeed');
e0 = 8.854e-12;

%% File Input

% Note: If extracting from simulation, be sure not to renormalize
% S-parameters
filepath = 'NRW_SimulationTest_teflon_6p3mm.s2p'; 

[~, fname, ~] = fileparts(filepath);

% Import touchstone file (https://github.com/njchorda/MATLAB-Touchstone-Reader)
S = SPARAMS(filepath);

% If you desire to restrict the frequency range
% f_range = [8e9 12e9];
% S.f = S.f(S.f > f_range(1) & S.f < f_range(2));
% S.S11 = S.S11(S.f > f_range(1) & S.f < f_range(2));
% S.S12 = S.S12(S.f > f_range(1) & S.f < f_range(2));
% S.S21 = S.S21(S.f > f_range(1) & S.f < f_range(2));
% S.S22 = S.S22(S.f > f_range(1) & S.f < f_range(2));

%% Dimensions

a = 22.86e-3; % Standard WR90 width
L = 6.3e-3; % Sample thickness of 6.3 mm


%% NRW Calculations
X = (S.S11.^2 - S.S21.^2 + 1)./(2*S.S11);

Gam1 = zeros(length(S.f), 1);
for i = 1:length(S.f)
    temp = X(i) + sqrt(X(i).^2 - 1);
    if abs(temp) <= 1
        Gam1(i) = temp;
    else
        Gam1(i) = X(i) - sqrt(X(i).^2 - 1);
    end
end

Z1 = (S.S11 + S.S21 - Gam1)./(1 - (S.S11 + S.S21).*Gam1);

lnZ1 = log(abs(Z1)) + 1i*(angle(Z1) + -2*pi*0);
invGamSq = -1*((lnZ1./(2.*pi.*L))).^2;
lam0 = c0./S.f;
lamc = 2.*a;
ura = (1 + Gam1).*sqrt(invGamSq)./((1 - Gam1).*sqrt((1./lam0.^2) - (1./lamc.^2)));

era = (lam0.^2./ura).*((1./lamc.^2) - (log(1./Z1)./(2*pi*L)).^2);
tanD = -imag(era)./real(era);
magTanD = imag(ura)./real(ura);

f = S.f;
derurdf = diff(era.*ura)./diff(f);
derurdf = [0; derurdf];
tCalc = (1./c0.^2).*L.*(f.*era.*ura + f.^2.*0.5.*derurdf)./sqrt(era.*ura.*f.^2/c0.^2 - 1./lamc.^2);
tCalc = real(tCalc);
dphidf = diff(unwrap(angle(Z1)))./diff(f);
dphidf = [0; dphidf];
tMeas = -1*dphidf./(2*pi);


%% Plot results

fig1 = figure(1);
subplot(2, 1, 1)
plot(S.f/1e9, real(era), 'r')
hold on
plot(S.f/1e9, abs(imag(era)), 'b')
ylabel('\epsilon')
legend({'Real', 'Imag.'}, 'Location','southeast');
ylim([0 8])
% ylim([0 14])
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'Line'), 'LineWidth', 4);
subplot(2, 1, 2)
plot(S.f/1e9, abs(tanD), 'r')
% ylim([0 1])
ylim([0 0.08])
ylabel('tan\delta')
xlabel('Frequency (GHz)')
xlim([8 12])
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'Line'), 'LineWidth', 4);
fig1.Position = [680 180 1186 698];

fig2 = figure(2);
subplot(2, 1, 1)
plot(S.f/1e9, real(ura), 'r')
hold on
plot(S.f/1e9, abs(imag(ura)), 'b')
ylabel('\mu')
legend({'Real', 'Imag.'}, 'Location','southeast');
ylim([0 8])
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'Line'), 'LineWidth', 4);

subplot(2, 1, 2)
plot(S.f/1e9, abs(magTanD), 'r')
ylim([0 0.08])
ylabel('tan\delta_m')
xlabel('Frequency (GHz)')
xlim([8 12])
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
set(findall(gcf, 'Type', 'Line'), 'LineWidth', 4);
fig2.Position = [680 180 1186 698];

%% Export figure if desired
% exportgraphics(fig1, [fname '.png'])

%% Display average value and at a specified frequency
disp('Averages:')
disp("er = " + num2str(mean(real(era))))
disp("tanD = " + num2str(mean(real(tanD))))
disp("ur = " + num2str(mean(real(ura))))
disp("magtanD = " + num2str(mean(real(magTanD))))

f_disp = 10e9;
disp("At " + num2str(f_disp/1e9) + " GHz")
disp("er = " + num2str((real(era(S.f == f_disp)))))
disp("tanD = " + num2str((real(tanD(S.f == f_disp)))))
disp("ur = " + num2str((real(ura(S.f == f_disp)))))
disp("magtanD = " + num2str((real(magTanD(S.f == f_disp)))))