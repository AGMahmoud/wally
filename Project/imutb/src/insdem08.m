%
%   insdem08.m
%      Static user with vertical gyro bias
%
%      - The accel bias from INSDEM06 has been set to zero
%      - The east gyro bias from INSDEM07 has been set to zero
%

clear

dph2rps = (pi/180)/3600;  % conversion factor going from
%                         % degrees-per-hour to radians-per-second

d_gyro_bias = 0.001*dph2rps;   % 0.001 deg/hr vertical (down) gyro bias
e_gyro_bias = 0*dph2rps;
n_accel_bias = 0;
deltat = 10;
time = 0:deltat:4*3600;
npts = max(size(time));

phi=0*pi/180;
theta=0*pi/180;
psi=0*pi/180;
DCMnb=eulr2dcm([phi theta psi]);  DCMbn = DCMnb';
               roll(1) = 0; pitch(1) = 0; yaw(1) = 0;

tru_lat = 45*pi/180;
tru_long = 45*pi/180;
tru_alpha = 0;
DCMel = llw2dcm([tru_lat tru_long tru_alpha]);

est_lat = tru_lat;
est_long = tru_long;
est_alpha = tru_alpha;

lat1 = tru_lat; lat2 = tru_lat;
vx1 = 0; vx2 = 0;
vy1= 0; vy2 = 0;
height1 = 0; height2 = 0;
vertmech = 0;
earthflg = 1;
vel_L(1,:) = [vx2 vy2 0];
vel2 = vel_L(1,:);  vel1 = vel2;

n_bias = n_accel_bias*deltat;
g = gravity(0,0);
accum_g = g*deltat;
delv_b = [n_bias 0 -accum_g];

DCMel_prof(1,1:3) = DCMel(1,1:3);              % Very simple profile since the
DCMel_prof(1,4:6) = DCMel(2,1:3);              % true user attitude remains at
DCMel_prof(1,7:9) = DCMel(3,1:3);              % [0 0 0] and the true user
DCMel_prof = [DCMel_prof; DCMel_prof];         % position is stationary at
DCMnb_prof(1,1:3) = DCMnb(1,1:3);              % [0 0 0]
DCMnb_prof(1,4:6) = DCMnb(2,1:3);
DCMnb_prof(1,7:9) = DCMnb(3,1:3);
DCMnb_prof = [DCMnb_prof; DCMnb_prof];

%                                        % Generate the earth-rate component
%                                        % of delta-theta
deltaer = earthrot([deltat; 2*deltat],DCMel_prof,DCMnb_prof);

acc_e_gyro_bias = e_gyro_bias*deltat;   % accumulate the biases to form the
acc_d_gyro_bias = d_gyro_bias*deltat;   % associated component of delta-theta 

dtherr = [0 acc_e_gyro_bias acc_d_gyro_bias]; % Form the delta-theta error vector

est_dtheta = deltaer + dtherr;     % Form the 'measured' delta-theta
%                                  % vector.  The vehicle is stationary 
%                                  % so the gyros should only measure 
%                                  % earth-rate.  However, here we are
%                                  % also simulating the effects of
%                                  % a single bias


C = [0 1 0; 1 0 0; 0 0 -1];    % conversion between NED and ENU

for i = 2:npts,
   td12 = time(i) - time(i-1);
   tdex = 0.5*td12;
   tdint = td12;
   
   DCMbn = bodupdat(DCMbn,est_dtheta);   % Update the body-to-nav DCM with
   %                                     % the gyro output.
   
   %                           % Compute the direction cosine matrix
   %                           % relating the angular displacement of
   %                           % the local level frame over the update
   %                           % interval.  Note that this accounts for
   %                           % earth-rate and craft-rate.
 	[DCM_ll_I,omega_el_L,omega_ie_L] = lclevupd(lat1,lat2,vx1,vx2,vy1,vy2,...
             height1,height2,td12,tdex,tdint,DCMel,vertmech,1,earthflg);
   %
   DCMbn = C*(DCM_ll_I*(C*DCMbn));     % Update the body-to-nav DCM to
   %                                % account for the motion of the
   %                                % local-level frame
   
   eul_vect = dcm2eulr(DCMbn);
   roll(i) = eul_vect(1);
   pitch(i) = eul_vect(2);
   yaw(i) = eul_vect(3);
   
   del_VL = C*(DCMbn*delv_b');    % Convert delta-V vector from the body
   %                              % frame to the local-level frame

   if i == 2,
     omega1_el_L = omega_el_L;
   else
      omega1_el_L = omega2_el_L;
   end
   omega2_el_L = omega_el_L;
   [DCMel, DCM_ll_E] = navupdat(omega1_el_L,omega2_el_L,td12,DCMel,1);
   %%[DCMel, DCM_ll_E] = navupd2(omega1_el_L,omega2_el_L,td12,DCMel,1);

   %                              % Update velocity
   vtmp = velupdat(vel2,vel1,td12,tdex,del_VL,omega_el_L,DCMel,g,0,td12);

   vel_L(i,:) = vtmp';
   
   vx1 = vx2; vy1 = vy2;
    vx2 = vel_L(i,1);  vy2 = vel_L(i,2);
    vel1 = vel2;  vel2 = vel_L(i,:);
    llw_vect = dcm2llw(DCMel);  lat1 = lat2;  lat2 = llw_vect(1);
    est_lat(i) = llw_vect(1); 
    est_long(i) = llw_vect(2);  
    est_alpha(i) = llw_vect(3);
end

close
subplot(211)
lat_err = (est_lat-tru_lat)*(180/pi)*3600;
long_err = (est_long-tru_long)*(180/pi)*3600;
plot(time/3600,lat_err,time/3600,long_err)
title('INSDEM08: 0.001 deg/hr Vertical Gyro Bias')
ylabel('error in arc-seconds')
xlabel('time in hours')
text(1.7,-1.5,'LAT')
text(3.1,-1.5,'LONG')
grid

subplot(212)
plot(time/3600,vel_L(:,1),time/3600,vel_L(:,2))
ylabel('velocity error in m/s')
xlabel('time in hours')
text(2.6,-0.0025,'EAST')
text(2.55,-0.013,'NORTH')
grid
%%print -dbitmap dem08a
pause

close
plot(time/3600,roll*3600*180/pi,time/3600,pitch*3600*180/pi)
title('INSDEM08:  Roll and Pitch Errors')
ylabel('error in arc-seconds')
xlabel('time in hours')
text(1,0.06,'pitch')
text(2.3,-0.002,'roll')
%%print -dbitmap dem08b
pause

close
plot(time/3600,yaw*3600*180/pi)
title('INSDEM08:  Yaw Angle Error')
ylabel('error in arc-seconds')
xlabel('time in hours')
%%print -dbitmap dem08c
