function [confType, confTypeStr] = getConfusionType(xyzTrue, xyzAnsw, flagMethod)

% xyzTrue is Nx3 cartesian target position 
% xyzAnsw is Nx3 cartesian subject answer position 
% flagMethod is a string, used to define the method used to flag confusions
% 
% assumes x positive is fwd, y positive is left, z positive is up (subject
% is always facing +x)

% get list of available flag methods
if( nargin == 0 )
    % confType = {'majdak', 'parseihian', 'katz', 'katz_no_poles', 'katz_polar_and_gc', 'katz_no_updown', 'katz_gc_only', 'poirier_cartesian_symetries', 'poirier', 'poirier_up_down', 'poirier_polar', 'poirier_isopolar'};
    confType = {'majdak', 'katz', 'katz_no_poles', 'poirier'};
    return
end

% sanity check
if( ~isequal( size(xyzTrue), size(xyzAnsw) ) ); error('different input sizes'); end
if( size(xyzTrue, 2) ~= 3 ); error('expected Nx3 vector'); end

% init locals
% s = struct();
% selVectPR = nan(size(xyzTrue, 1), 1);
% selVectCB = nan(size(xyzTrue, 1), 1);
% selVectFB = nan(size(xyzTrue, 1), 1);
% selVectUD = nan(size(xyzTrue, 1), 1);
% selVectUDFB = nan(size(xyzTrue, 1), 1);

% coordinates conversion
interTrue = dpq.coord.cart2inter( xyzTrue );
interAnsw = dpq.coord.cart2inter( xyzAnsw );
sphTrue = dpq.coord.cart2sph( xyzTrue );
sphAnsw = dpq.coord.cart2sph( xyzAnsw );

switch flagMethod

    
%% Quadrant based confusions as used in [majdak 2010]
% Majdak, Piotr, Matthew J. Goupell, and Bernhard Laback. "3-D 
% localization of virtual sound sources: Effects of visual environment, 
% pointing method, and training." Attention, perception, & psychophysics 
% 72.2 (2010): 454-469.

case 'majdak'
    
    % init local 
    s = struct('precision', [], 'others', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % precision
    polarError = abs( interTrue(:,2) - interAnsw(:,2) );
    w = 0.5 * cosd( 2 * interTrue(:,1) ) + 0.5;
    s.precision = (w .* polarError) <= angleThresh;

    % others (flagged as combined for uniformity with other methods)
    s.others = ~s.precision;

   
%% Method defined and used in [parseihian 2012]
% Parseihian, Gaëtan, and Brian FG Katz. "Rapid head-related transfer 
% function adaptation using a virtual auditory environment." The Journal 
% of the Acoustical Society of America 131.4 (2012): 2948-2957.

case 'parseihian'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'combined', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % rewrap elev around [0 360], ease computation for this scheme
    selVect = interTrue(:,2) < -90;
    interTrue(selVect,2) = 360 + interTrue(selVect,2);
    selVect = interAnsw(:,2) < -90;
    interAnsw(selVect,2) = 360 + interAnsw(selVect,2);

    % precision
    polDist = abs( interTrue(:,2) - interAnsw(:,2) );
    s.precision = polDist <= angleThresh;

    % front-back
    p = interTrue(:,2) + 2*(90-interTrue(:,2));
    s.front_back = abs( p - interAnsw(:,2) ) < angleThresh;

    % up-down: lower region
    p = interTrue(:,2) + 2*(0-interTrue(:,2));
    s.up_down = abs( p - interAnsw(:,2) ) < angleThresh;

    % up-down: upper region
    p = interTrue(:,2) + 2*(180-interTrue(:,2));
    s.up_down = s.up_down | abs( p - interAnsw(:,2) ) < angleThresh;

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;
    s.up_down = s.up_down & ~s.precision;

    % combined confusions are any non taken region or overlap between other confusions
    s.combined = ~(s.precision | s.front_back | s.up_down);


%% Improving upon [parseihian 2012] method, fixing forgotten exclusion zones, defined in [zagala 2020]
% Zagala, Franck, Markus Noisternig, and Brian FG Katz. "Comparison of 
% direct and indirect perceptual head-related transfer function selection 
% methods." The Journal of the Acoustical Society of America 147.5 (2020): 
% 3376-3389.

case 'katz'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'combined', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % precision
    polDist = abs( interTrue(:,2) - interAnsw(:,2) );
    s.precision = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % front-back (within angleThresh polar distance from target symmetry with X axis)
    interTrueSym = dpq.coord.cart2inter( [-xyzTrue(:,1) xyzTrue(:,2:3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % up-down (within angleThresh polar distance from target symmetry with Z axis)
    interTrueSym = dpq.coord.cart2inter( [xyzTrue(:,1:2) -xyzTrue(:,3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.up_down = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;
    s.up_down = s.up_down & ~s.precision;

    % combined confusions are any non taken region or overlap between other confusions
    s.combined = ~(s.precision | s.front_back | s.up_down);


%% same as katz but using lateral < angle thresh to discard confusions at the interaural coord. poles

case 'katz_no_poles'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'combined', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % precision
    polDist = abs( interTrue(:,2) - interAnsw(:,2) );
    s.precision = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );
   
    % every confusion becomes a precision confusion near the poles (based
    % on lateral angle), to avoid error inflation due to interaural pole
    % compression
    selVectNeutralLR = abs(interTrue(:,1)) > (90 - angleThresh/2) & abs(interTrue(:,1)) < (90 + angleThresh/2);
    s.precision = s.precision | selVectNeutralLR;   

    % front-back (within angleThresh polar distance from target symmetry with X axis)
    interTrueSym = dpq.coord.cart2inter( [-xyzTrue(:,1) xyzTrue(:,2:3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % up-down (within angleThresh polar distance from target symmetry with Z axis)
    interTrueSym = dpq.coord.cart2inter( [xyzTrue(:,1:2) -xyzTrue(:,3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.up_down = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % % error near the center band becomes precision if not already flagged as up-down / front-back
    % selVectNeutralCenter = abs(interTrue(:,1)) < angleThresh/2;
    % s.precision = s.precision | (selVectNeutralCenter & ~( s.up_down & s.front_back ) );

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;
    s.up_down = s.up_down & ~s.precision;

    % combined confusions are any non taken region or overlap between other confusions
    s.combined = ~(s.precision | s.front_back | s.up_down);


%% same as katz but using gc < angle thresh in addition to polar < angle thresh

case 'katz_polar_and_gc'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'combined', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % precision
    polDist = abs( interTrue(:,2) - interAnsw(:,2) );
    s.precision = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );
    
    % add gc < angleThresh to precision (to partially avoid compression at
    % the poles issues)
    gc = dpq.alet.getGreatCircleAngle(xyzTrue, xyzAnsw);
    s.precision = s.precision | gc < angleThresh;

    % front-back (within angleThresh polar distance from target symmetry with X axis)
    interTrueSym = dpq.coord.cart2inter( [-xyzTrue(:,1) xyzTrue(:,2:3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % up-down (within angleThresh polar distance from target symmetry with Z axis)
    interTrueSym = dpq.coord.cart2inter( [xyzTrue(:,1:2) -xyzTrue(:,3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.up_down = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;
    s.up_down = s.up_down & ~s.precision;
    % selVectLR = selVectLR & ~selVectPR;

    % combined confusions are any non taken region or overlap between other confusions
    s.combined = ~(s.precision | s.front_back | s.up_down);

    
%% Same as katz, with only fb confusions

case 'katz_no_updown'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'generalized', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % precision
    polDist = abs( interTrue(:,2) - interAnsw(:,2) );
    s.precision = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % front-back (within angleThresh polar distance from target symmetry with X axis)
    interTrueSym = dpq.coord.cart2inter( [-xyzTrue(:,1) xyzTrue(:,2:3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;

    % combined confusions are any non taken region or overlap between other confusions
    s.generalized = ~(s.precision | s.front_back);
   

%% new proposed classification 
% same as katz but with precision confusion defined based on gc angle

case 'katz_gc_only'
    
    % init local 
    % s = struct('precision', [], 'front_back', [], 'up_down', [], 'combined', []);
    s = struct('precision', [], 'front_back', [], 'combined', []);
    angleThresh = 45; % confusion angle threshold (in degree)

    % great-cricle
    gc = dpq.alet.getGreatCircleAngle(xyzTrue, xyzAnsw);

    % precision (within angleThresh gc distance from target)
    s.precision = gc < angleThresh;

    % front-back (within angleThresh polar distance from target symmetry with X axis)
    interTrueSym = dpq.coord.cart2inter( [-xyzTrue(:,1) xyzTrue(:,2:3)] );
    polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % % up-down (within angleThresh polar distance from target symmetry with Z axis)
    % interTrueSym = dpq.coord.cart2inter( [xyzTrue(:,1:2) -xyzTrue(:,3)] );
    % polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
    % s.up_down = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );

    % precision confusions win over any other single confusion
    s.front_back = s.front_back & ~s.precision;
    % s.up_down = s.up_down & ~s.precision;

    % combined confusions are any non taken region or overlap between other confusions
    % s.combined = ~(s.precision | s.front_back | s.up_down);
    s.combined = ~(s.precision | s.front_back);


%% New proposed method, based on great-circle angle regions
% using symetry wrt cartesian planes (XoY, YoZ, ZoX) to define confusion 
% types  

case 'poirier_cartesian_symetries'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'front_back_up_down', [], 'left_right', [], 'undetermined', []);
    angleThresh = 45; % confusion angle threshold (in degree)
    angleThresh2 = 20; % exclusion region angle (in degree)

    % great-cricle
    gc = dpq.alet.getGreatCircleAngle(xyzTrue, xyzAnsw);

    % precision (within angleThresh gc distance from target)
    s.precision = gc < angleThresh;

    % front-back (within angleThresh gc distance from target symmetry with X axis)
    s.front_back = dpq.alet.getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2:3)]) < angleThresh;

    % up-down (... symmetry with Z axis)
    s.up_down = dpq.alet.getGreatCircleAngle(xyzTrue, [xyzAnsw(:,1:2) -xyzAnsw(:,3)]) < angleThresh;

    % combined front back and up-down (diagonal, ... symmetry with X then Z axis)
    s.front_back_up_down = dpq.alet.getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2) -xyzAnsw(:,3)])  < angleThresh;

    % left-right (... symmetry with Y axis)
    s.left_right = dpq.alet.getGreatCircleAngle(xyzTrue, [xyzAnsw(:,1) -xyzAnsw(:,2) xyzAnsw(:,3)]) < angleThresh;

    % define priorities
    s.front_back = s.front_back & ~s.precision; % precision confusion wins over fb
    s.up_down = s.up_down & ~(s.precision | s.front_back); % precision and fb confusion win over ud. fb > ud is arbitrary choice.
    s.front_back_up_down = s.front_back_up_down & ~(s.front_back | s.up_down | s.precision); % pr, fb and ud confusions win over combined ud-fb
    s.left_right = s.left_right & ~(s.precision | s.front_back | s.up_down | s.front_back_up_down); % every one win over lr

    % combined confusions are any non taken region
    s.undetermined = ~(s.precision | s.front_back | s.up_down | s.left_right | s.front_back_up_down);


%% new proposed classification (the one published in 2022 Intech chapter)
% mix between cone-of-confusion and quadrant, trying to make a parseihian 
% that feels ok on the whole sphere
%
% how to use:
% 
% is it
%     - precision
%     - in-cone
%     - off cone
% 
% if its in-cone
%     - is it front-back or not
% 
% if it's off-cone
%     - check why, make sure you understand, otherwise there is a critical problem in the experiment
% 
% -> avoid biasing the analysis by saying that "this has an impact on front-back confusions" while one of your confusion just redistributed those confusions from in-cone vs. front-back

case 'poirier'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'in_cone', [], 'off_cone', []);

    % init thresholds
    angleThresh = 45; % confusion angle threshold (in degree)

    % great-cricle
    gc = dpq.alet.getGreatCircleAngle(xyzTrue, xyzAnsw);

    % precision (within angleThresh gc distance from target)
    s.precision = gc < angleThresh;

    % front-back (within angleThresh gc distance from target symmetry with X axis)
    s.front_back = dpq.alet.getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2:3)]) < angleThresh;
    
    % generalised-confusion (remainder of cone of confusion)
    s.in_cone = abs(interTrue(:, 1) - interAnsw(:, 1)) < angleThresh;

    % define priorities
    s.front_back = s.front_back & ~s.precision; % precision confusion wins over fb
    s.in_cone = s.in_cone & ~(s.front_back | s.precision); % remainder of the cone of confusion

    % off-cone confusions are any non taken region
    s.off_cone = ~(s.precision | s.front_back | s.in_cone);


%% same as poirier but with up-down and front-back-up-down confusions added
% mix between cone-of-confusion and quadrant, trying to make a parseihian 
% that feels ok on the whole sphere

case 'poirier_up_down'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'front_back_up_down', [], 'generalised_confusion', [], 'off_cone', []);

    % init thresholds
    angleThresh = 45; % confusion angle threshold (in degree)

    % great-cricle
    gc = dpq.alet.getGreatCircleAngle(xyzTrue, xyzAnsw);

    % precision (within angleThresh gc distance from target)
    s.precision = gc < angleThresh;

    % front-back (within angleThresh gc distance from target symmetry with X axis)
    s.front_back = dpq.alet.getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2:3)]) < angleThresh;
    
    % up-down (... symmetry with Z axis)
    s.up_down = dpq.alet.getGreatCircleAngle(xyzTrue, [xyzAnsw(:,1:2) -xyzAnsw(:,3)]) < angleThresh;

    % combined front back and up-down (diagonal, ... symmetry with X then Z axis)
    s.front_back_up_down = dpq.alet.getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2) -xyzAnsw(:,3)])  < angleThresh;
    
    % generalised-confusion (remainder of cone of confusion)
    s.generalised_confusion = abs(interTrue(:, 1) - interAnsw(:, 1)) < angleThresh;

    % define priorities
    s.front_back = s.front_back & ~s.precision; % precision confusion wins over fb
    s.up_down = s.up_down & ~(s.precision | s.front_back); % precision and fb confusion win over ud. fb > ud is arbitrary choice.
    s.front_back_up_down = s.front_back_up_down & ~(s.front_back | s.up_down | s.precision); % pr, fb and ud confusions win over combined ud-fb
    s.generalised_confusion = s.generalised_confusion & ~(s.front_back | s.up_down | s.precision | s.front_back_up_down ); % remainder of the cone of confusion

    % off-cone confusions are any non taken region
    s.off_cone = ~(s.precision | s.front_back | s.up_down | s.front_back_up_down | s.generalised_confusion);

    
%% new proposed classification
% same as poirier but with polar/lateral angle to define zones limits
% rather than gc angle

case 'poirier_polar'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'up_down', [], 'front_back_up_down', [], 'generalised_confusion', [], 'off_cone', []);
    angleThresh = 45; % confusion angle threshold (in degree)
    
    % off cone errors
    s.off_cone = abs(interAnsw(:, 1) - interTrue(:, 1)) > angleThresh;
    
    % precision (within cone and polar)
    s.precision = ~s.off_cone & abs(interAnsw(:, 2) - interTrue(:, 2)) < angleThresh;

    % front-back (within polar angle distance from target symmetry with X axis)
    interSym = dpq.coord.cart2inter([-xyzAnsw(:,1) xyzAnsw(:,2:3)]);
    s.front_back = ~s.off_cone & abs(interSym(:, 2) - interTrue(:, 2)) < angleThresh;
    
    % up-down (... symmetry with Z axis)
    interSym = dpq.coord.cart2inter([xyzAnsw(:,1:2) -xyzAnsw(:,3)]);
    s.up_down = ~s.off_cone & abs(interSym(:, 2) - interTrue(:, 2)) < angleThresh;
    
    % combined front back and up-down (diagonal, ... symmetry with X then Z axis)
    interSym = dpq.coord.cart2inter([-xyzAnsw(:,1) xyzAnsw(:,2) -xyzAnsw(:,3)]);
    s.front_back_up_down  = ~s.off_cone & abs(interSym(:, 2) - interTrue(:, 2)) < angleThresh;
    
    % generalised-confusion (remainder of cone of confusion)
    s.generalised_confusion = ~(s.precision | s.front_back | s.up_down | s.front_back_up_down | s.off_cone);

    % define priorities
    s.front_back = s.front_back & ~s.precision; % precision confusion wins over fb
    s.up_down = s.up_down & ~(s.precision | s.front_back); % precision and fb confusion win over ud. fb > ud is arbitrary choice.
    s.front_back_up_down = s.front_back_up_down & ~(s.front_back | s.up_down | s.precision); % pr, fb and ud confusions win over combined ud-fb

    
%% new proposed classification 
% same as katz but solving problem at poles (using patches that grow in polar ange to keep a constant gc value)

case 'poirier_isopolar'
    
    % init local 
    s = struct('precision', [], 'front_back', [], 'in_cone', [], 'off_cone', []);
    angleThresh = 45; % confusion angle threshold (in degree)
    
    % project (ignore polar angle of true target)
%     interTrueTmp = [interTrue(:, 1) interAnsw(:, 2) interTrue(:, 3)];
%     xyzTrueTmp = dpq.coord.inter2cart(interTrueTmp);

    % off cone errors
    s.off_cone = abs(interAnsw(:, 1) - interTrue(:, 1)) > angleThresh;
%     s.off_cone = dpq.alet.getGreatCircleAngle(xyzTrueTmp, xyzAnsw) > angleThresh; 
    % s.precision = gc <= angleThresh;
    
%     % precision (within cone and polar)
%     s.precision = ~s.off_cone & abs(interAnsw(:, 2) - interTrue(:, 2)) < angleThresh;
    
    % project (ignore lateral angle of true target)
    interTrueTmp = [interAnsw(:, 1) interTrue(:, 2:3)];
    xyzTrueTmp = dpq.coord.inter2cart(interTrueTmp);
    
    % precision
    s.precision = dpq.alet.getGreatCircleAngle(xyzTrueTmp, xyzAnsw) <= angleThresh;
    
    
%     % front-back (within angleThresh polar distance from target symmetry with X axis)
%     interTrueSym = dpq.coord.cart2inter( [-xyzTmp(:,1) xyzTmp(:,2:3)] );
%     polDist = abs( interTrueSym(:, 2) - interAnsw(:,2) );
%     s.front_back = ( polDist <= angleThresh ) | ( polDist >= (360-angleThresh) );
    
    % front-back (within angleThresh gc distance from target symmetry with X axis)
    s.front_back = dpq.alet.getGreatCircleAngle(xyzTrueTmp, [-xyzAnsw(:,1) xyzAnsw(:,2:3)]) <= angleThresh;
    
    % precision confusions win over any other single confusion
%     s.front_back = s.front_back & ~s.precision;
    
    % priorities
    s.precision = s.precision & ~s.off_cone;
    s.front_back = s.front_back & ~(s.precision | s.off_cone);
    % s.off_cone = s.off_cone & ~(s.precision | s.front_back);
    
    % in-cone (remainder)
    s.in_cone = ~(s.off_cone | s.precision | s.front_back);

%     % project (ignore polar angle of true target)
%     interTrueTmp = [interTrue(:, 1) interAnsw(:, 2) interTrue(:, 3)];
%     xyzTrueTmp = dpq.coord.inter2cart(interTrueTmp);
%     
%     % in cone
%     gc = dpq.alet.getGreatCircleAngle(xyzTrueTmp, xyzAnsw);
%     s.in_cone = gc <= angleThresh;
%     s.in_cone = s.in_cone & ~(s.precision | s.front_back);
%     
%     % in cone is all that remains
% %     s.in_cone = ~s.off_cone & ~s.precision & ~s.front_back;
%     
%     % off cone errors
%     s.off_cone = ~(s.in_cone | s.precision | s.front_back);
%     s.off_cone = abs(interAnsw(:, 1) - interTrue(:, 1)) > angleThresh;
    
    
%% default is error

otherwise

error('undefined flagMethod: %s', flagMethod);

end


%% assign names / int to error outputs

% init local 
confType = nan(size(xyzTrue, 1),1);
confTypeStr = cell(size(confType));
confNames = fieldnames(s);

% loop over confusion types
for iConf = 1:length(confNames)
    
    % select data
    selVect = s.(confNames{iConf}); 
    
    % assign output
    confType(selVect) = iConf - 1;
    confTypeStr(selVect) = { strrep(confNames{iConf}, '_', '-') };
    
end


%% sanity check 

% init locals
sumVect = zeros(size(xyzTrue, 1),1);

% loop over confusion types
for iConf = 1:length(confNames)
    
    % select data
    selVect = s.(confNames{iConf}); 
    
    % save to output
    sumVect = sumVect + 1*selVect;
end

if( ~isequal(sumVect, ones(size(xyzTrue, 1),1)) )
    error('under or over defined confusions');
end


return 


%% debug function: plot polar confusion zones

% create fake positions
n = 100000;
% interTrue = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
% interAnsw = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
%
% interTrue = [ -180*rand(n,1), 180*rand(n,1), ones(n,1) ];
% interAnsw = [ -180*rand(n,1), 180*rand(n,1), ones(n,1) ];

% iso-lateral angle (cleaner 2D plot)
lat = 30;
% lat = 30;
% lat = 60;
% interTrue = [ lat * ones(n,1), 360*rand(n,1) - 90, ones(n,1) ];
% interAnsw = [ lat * ones(n,1), 360*rand(n,1) - 90, ones(n,1) ];
%
interTrue = [ lat * ones(n,1), 360*(rand(n,1)-0.5), ones(n,1) ];
interAnsw = [ lat * ones(n,1), 360*(rand(n,1)-0.5), ones(n,1) ];

% from polar [-180:180] to polar [-90:270] for the plot
interTrue(:, 2) = interTrue(:, 2) + 90;
interAnsw(:, 2) = interAnsw(:, 2) + 90;

% compute conf type
% {'majdak', 'parseihian', 'katz', 'katz_no_poles', 'katz_polar_and_gc', 'katz_no_updown', 'katz_gc_only', 'poirier_cartesian_symetries', 'poirier', 'poirier_up_down', 'poirier_polar', 'poirier_isopolar'}
method = 'katz';
[confType, confTypeStr] = dpq.alet.getConfusionType(dpq.coord.inter2cart(interTrue), dpq.coord.inter2cart(interAnsw), method);

% plot interaural spawn vs hit
confTypeColors = [ 0.6 0.6 0.6; .9 .3 .2; .3 .75 .3; 0.3 0.6 .9; .2 .2 .2; .9 .9 .9];
cmap = confTypeColors(confType+1,:);
scatter(interTrue(:,2), interAnsw(:,2), 5, cmap, 'filled', 'HandleVisibility', 'off');

% legend
[confId, id] = unique(confType);
confStr = confTypeStr(id);
hold on,
for iConf = 1:length(confId)
    scatter(0, 0, nan, confTypeColors(confId(iConf)+1,:), 'filled');
    confTypeColors(confId(iConf)+1,:);
end
hold off,
legend(confStr, 'Location', 'eastoutside');

% format
axis equal
grid on
% xticks(-180:45:180); yticks(-180:45:180);
xticks(-90:45:270); yticks(-90:45:270);
xlabel('target polar angle (deg)');
ylabel('response polar angle (deg)');

title(sprintf('lateral angle (deg): %d', lat));

% if the ITD is wrong, shift your lateral angle to average to do relative
% cone of confusion per-participant

% % save figure to disk
% fileName = sprintf('%s2D_%d', method, lat);
% print(fullfile('~', 'Desktop', 'debug_conf', fileName), '-djpeg');


%% debug function: check confusions by types on 3D sphere

% lateral error
% precision
% green: generalised cone error
% red: front-back


% create fake positions
n = 40000;
% interTrue = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
aedTrue = repmat([45.1 + 45/2 0 1.2], n, 1);
% aedTrue = repmat([30 15 1.2], n, 1);
% aedTrue = repmat([60 45 1.2], n, 1);
xyzTrue = dpq.coord.sph2cart(aedTrue);

interAnsw = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
xyzAnsw = dpq.coord.inter2cart( interAnsw );
aedAnsw = dpq.coord.inter2sph( interAnsw );

% create confusion
% xyzAnsw = [ -xyzTrue(:,1), xyzTrue(:,2), xyzTrue(:,3) ] % front-back
% xyzAnsw = [ xyzTrue(:,1), xyzTrue(:,2), -xyzTrue(:,3) ] % up-down
% xyzAnsw = [ xyzTrue(:,1), -xyzTrue(:,2), xyzTrue(:,3) ] % left-right
% xyzAnsw = [ -xyzTrue(:,1), -xyzTrue(:,2), -xyzTrue(:,3) ] % combined

% compute conf type
% {'majdak', 'parseihian', 'katz', 'katz_no_poles', 'katz_polar_and_gc', 'katz_no_updown', 'katz_gc_only', 'poirier_cartesian_symetries', 'poirier', 'poirier_up_down', 'poirier_polar', 'poirier_isopolar'}
method = 'poirier';
[confType, confTypeStr] = dpq.alet.getConfusionType(xyzTrue, xyzAnsw, method);

% init plot
plot3D = true;
confTypeColors = [ 0.6 0.6 0.6; .9 .3 .2; .3 .8 .3; 0 0.6 1; 0 0 0; .9 .9 .9];
% gray: precision, red: front-back, green: up-down, blue: left-right, black: combined
cmap = confTypeColors(confType+1,:);

% plot 
if( plot3D )
    scatter3(xyzAnsw(:,1), xyzAnsw(:,2), xyzAnsw(:,3), 20, cmap, 'filled', 'HandleVisibility', 'off');
    hold on, 
    scatter3(xyzTrue(1,1), xyzTrue(1,2), xyzTrue(1,3), 1000, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2); % source
    % scatter3(1.2, 0, 0, 1000, 1*[1 1 1], 'filled', 'Marker', '^', 'MarkerEdgeColor', 'k', 'LineWidth', 2); % user forward
    line([0 1.2], [0 0], [0 0], 'Color', 'k', 'LineWidth', 10);
    hold off
else
    % spherical
    % angleAnsw = aedAnsw; angleTrue = aedTrue; 
    % interaural
    angleAnsw = interAnsw; angleTrue = interTrue; 
    %
    scatter(angleAnsw(:,1), angleAnsw(:,2), 20, cmap, 'filled', 'HandleVisibility', 'off');
    hold on, 
    scatter(angleTrue(1,1), angleTrue(1,2), 600, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2); % source
    scatter3(1.2, 0, 0, 600, 1*[1 1 1], 'filled', 'Marker', '^', 'MarkerEdgeColor', 'k', 'LineWidth', 2); % user forward
    % line([0 1.2], [0 0], [0 0], 'Color', 'w', 'LineWidth', 10);
    hold off
end

% legend
[confId, id] = unique(confType);
confStr = confTypeStr(id);
hold on,
for iConf = 1:length(confId)
    scatter(0, 0, nan, confTypeColors(confId(iConf)+1,:), 'filled');
    confTypeColors(confId(iConf)+1,:);
end
hold off,
legend(confStr, 'Location', 'eastoutside');

% format
grid on, grid minor 

% format specific
if( plot3D )
    xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
    axis equal, rotate3d on,
    view([160 24]);
else
    xlabel('azimuth (deg)');
    ylabel('elevation (deg)');
end

% format
legend([{'source'; 'usr fwd'}; confStr]);
% view([180 0]);
title(sprintf('source azim/elev: (%d, %d)', aedTrue(1,1), aedTrue(1, 2)));

% % save figure to disk
% fileName = sprintf('%s_%d_%d', method, aedTrue(1,1:2));
% print(fullfile('~', 'Desktop', 'debug_conf', fileName), '-djpeg');



