function [confType, confTypeStr] = getConfusionType(xyzTrue, xyzAnsw, flagMethod)

% xyzTrue is Nx3 cartesian target position 
% xyzAnsw is Nx3 cartesian subject answer position 
% flagMethod is a string, used to define the method used to flag confusions
% 
% assumes x positive is fwd, y positive is left, z positive is up (subject
% is always facing +x)

% get list of available flag methods
if( nargin == 0 )
    confType = {'majdak', 'parseihian', 'zagala', 'poirier'};
    return
end

% sanity check
if( ~isequal( size(xyzTrue), size(xyzAnsw) ) ); error('different input sizes'); end
if( size(xyzTrue, 2) ~= 3 ); error('expected Nx3 vector'); end


switch flagMethod

    
%% Quadrant based confusions as used in [majdak 2010]
% Majdak, Piotr, Matthew J. Goupell, and Bernhard Laback. "3-D 
% localization of virtual sound sources: Effects of visual environment, 
% pointing method, and training." Attention, perception, & psychophysics 
% 72.2 (2010): 454-469.

case 'majdak'
    
% init thresholds
angleThresh = 45; % confusion angle threshold (in degree)

% cartesian to interaural coordinates
interTrue = cart2interVect( xyzTrue );
interAnsw = cart2interVect( xyzAnsw );

% precision
polarError = abs( interTrue(:,2) - interAnsw(:,2) );
w = 0.5 * cosd( 2 * interTrue(:,1) ) + 0.5;
selVectPR = (w .* polarError) <= angleThresh;

% others (flagged as combined for uniformity with other methods)
selVectCB = ~selVectPR;

% default others (for uniformity with other methods)
selVectLR = false(size(selVectCB));
selVectFB = selVectLR;
selVectUD = selVectLR;


%% Method defined and used in [parseihian 2012]
% Parseihian, Gaëtan, and Brian FG Katz. "Rapid head-related transfer 
% function adaptation using a virtual auditory environment." The Journal 
% of the Acoustical Society of America 131.4 (2012): 2948-2957.

case 'parseihian'
    
% init thresholds
angleThresh = 45; % confusion angle threshold (in degree)

% cartesian to interaural coordinates
interTrue = cart2interVect( xyzTrue );
interAnsw = cart2interVect( xyzAnsw );

% precision
selVectPR = abs( interTrue(:,2) - interAnsw(:,2) ) <= angleThresh;
% % % take into account space fold extremities
% selVectPR = selVectPR | abs( interTrue(:,2) - (interAnsw(:,2) - 360) ) <= angleThresh;
% selVectPR = selVectPR | abs( interTrue(:,2) - (interAnsw(:,2) + 360) ) <= angleThresh;

% front-back
p = interTrue(:,2) + 2*(90-interTrue(:,2));
selVectFB = abs( p - interAnsw(:,2) ) < angleThresh;

% up-down: lower region
p = interTrue(:,2) + 2*(0-interTrue(:,2));
selVectUD = abs( p - interAnsw(:,2) ) < angleThresh;
% up-down: upper region
p = interTrue(:,2) + 2*(180-interTrue(:,2));
selVectUD = selVectUD | abs( p - interAnsw(:,2) ) < angleThresh;

% left-right
% selVectLR = interTrue(:,1) < 0 & interAnsw(:,1) > 0 | interTrue(:,1) > 0 & interAnsw(:,1) < -0;
selVectLR = false(size(interTrue, 1), 1); % dummy (none)

% % error near the center band becomes precision if not already flagged as up-down / front-back
% selVectNeutralCenter = abs(interTrue(:,1)) < angleThresh/2;
% selVectPR = selVectPR | (selVectNeutralCenter & ~( selVectUD & selVectFB ) );

% % error near the L/R poles becomes precision confusion if not already flagged as left-right
% selVectNeutralLR = abs(interTrue(:,1)) > (90 - angleThresh/2) & abs(interTrue(:,1)) < (90 + angleThresh/2);
% selVectPR = selVectPR | (selVectNeutralLR & ~selVectLR);

% precision confusions win over any other single confusion
selVectFB = selVectFB & ~selVectPR;
selVectUD = selVectUD & ~selVectPR;
selVectLR = selVectLR & ~selVectPR;

% combined confusions are any non taken region or overlap between other confusions
selVectCB = ~(selVectPR | selVectFB | selVectUD | selVectLR);
selVectCB = selVectCB | (selVectFB & selVectUD) | (selVectFB & selVectLR) | (selVectUD & selVectLR);

% combined confusions wins over all confusions
selVectPR = selVectPR & ~selVectCB;
selVectFB = selVectFB & ~selVectCB;
selVectUD = selVectUD & ~selVectCB;
selVectLR = selVectLR & ~selVectCB;

% [selVectPR, selVectFB, selVectUD, selVectLR, selVectCB]


%% Improving upon [parseihian 2012] method, fixing forgotten exclusion zones, defined in [zagala 2020]
% Zagala, Franck, Markus Noisternig, and Brian FG Katz. "Comparison of 
% direct and indirect perceptual head-related transfer function selection 
% methods." The Journal of the Acoustical Society of America 147.5 (2020): 
% 3376-3389.

case 'zagala'
    
% init thresholds
angleThresh = 45; % confusion angle threshold (in degree)

% cartesian to interaural coordinates
interTrue = cart2interVect( xyzTrue );
interAnsw = cart2interVect( xyzAnsw );

% precision
selVectPR = abs( interTrue(:,2) - interAnsw(:,2) ) <= angleThresh;
% % take into account space fold extremities
selVectPR = selVectPR | abs( interTrue(:,2) - (interAnsw(:,2) - 360) ) <= angleThresh;
selVectPR = selVectPR | abs( interTrue(:,2) - (interAnsw(:,2) + 360) ) <= angleThresh;

% front-back
p = interTrue(:,2) + 2*(90-interTrue(:,2));
selVectFB = abs( p - interAnsw(:,2) ) <= angleThresh;

% up-down: lower region
p = interTrue(:,2) + 2*(0-interTrue(:,2));
selVectUD = abs( p - interAnsw(:,2) ) <= angleThresh;
% up-down: upper region
p = interTrue(:,2) + 2*(180-interTrue(:,2));
selVectUD = selVectUD | abs( p - interAnsw(:,2) ) <= angleThresh;

% left-right
% selVectLR = interTrue(:,1) < 0 & interAnsw(:,1) > 0 | interTrue(:,1) > 0 & interAnsw(:,1) < -0;
selVectLR = false(size(interTrue, 1), 1); % dummy (none)

% % error near the center band becomes precision if not already flagged as up-down / front-back
% selVectNeutralCenter = abs(interTrue(:,1)) < angleThresh/2;
% selVectPR = selVectPR | (selVectNeutralCenter & ~( selVectUD & selVectFB ) );

% error near the L/R poles becomes precision confusion if not already flagged as left-right
selVectNeutralLR = abs(interTrue(:,1)) > (90 - angleThresh/2) & abs(interTrue(:,1)) < (90 + angleThresh/2);
selVectPR = selVectPR | (selVectNeutralLR & ~selVectLR);

% precision confusions win over any other single confusion
selVectFB = selVectFB & ~selVectPR;
selVectUD = selVectUD & ~selVectPR;
selVectLR = selVectLR & ~selVectPR;

% combined confusions are any non taken region or overlap between other confusions
selVectCB = ~(selVectPR | selVectFB | selVectUD | selVectLR);
selVectCB = selVectCB | (selVectFB & selVectUD) | (selVectFB & selVectLR) | (selVectUD & selVectLR);

% combined confusions wins over all confusions
selVectPR = selVectPR & ~selVectCB;
selVectFB = selVectFB & ~selVectCB;
selVectUD = selVectUD & ~selVectCB;
selVectLR = selVectLR & ~selVectCB;

% [selVectPR, selVectFB, selVectUD, selVectLR, selVectCB]


%% New proposed method, based on great-circle angle regions

case 'poirier'
    
% init thresholds
angleThresh = 45; % confusion angle threshold (in degree)
angleThresh2 = 20; % exclusion region angle (in degree)

% cartesian to interaural / spherical coordinates
interTrue = cart2interVect( xyzTrue );
interAnsw = cart2interVect( xyzAnsw );
%
sphTrue = cart2sphVect( xyzTrue );
sphAnsw = cart2sphVect( xyzAnsw );

% great-cricle
gc = getGreatCircleAngle(xyzTrue, xyzAnsw);

% precision
selVectPR = gc < angleThresh;

% front-back
selVectFB = ~ ( ( abs(interTrue(:,1)) > (90-angleThresh2) ) & ( abs(interTrue(:,1)) < (90+angleThresh2) ) ); % exclude equator
selVectFB = selVectFB & sign(xyzTrue(:,1)) == -sign(xyzAnsw(:,1)); % opposite quadrants
gcXsym = getGreatCircleAngle(xyzTrue, [-xyzAnsw(:,1) xyzAnsw(:,2:3)]);
selVectFB = selVectFB & gcXsym < angleThresh; % answer is indeed in "quadrant" opposed to target wrt x axis

% up-down
selVectUD = ( abs(sphTrue(:,2)) > angleThresh2 ); % exclude equator
% selVectUD = ( abs(interTrue(:,2)) > angleThresh2 ); % exclude equator
selVectUD = selVectUD & sign(xyzTrue(:,3)) == -sign(xyzAnsw(:,3)); % opposite quadrants
gcZsym = getGreatCircleAngle(xyzTrue, [xyzAnsw(:,1:2) -xyzAnsw(:,3)]);
selVectUD = selVectUD & gcZsym < angleThresh; % answer is indeed in "quadrant" opposed to target wrt z axis

% left-right
selVectLR = ( abs(interTrue(:,1)) > angleThresh2 ) & ( abs(interTrue(:,1)) < (180-angleThresh2) ); % exclude equator
selVectLR = selVectLR & sign(xyzTrue(:,2)) == -sign(xyzAnsw(:,2)); % opposite quadrants
gcYsym = getGreatCircleAngle(xyzTrue, [xyzAnsw(:,1) -xyzAnsw(:,2) xyzAnsw(:,3)]);
selVectLR = selVectLR & gcYsym < angleThresh; % answer is indeed in "quadrant" opposed to target wrt y axis

% precision confusions win over any other single confusion
selVectFB = selVectFB & ~selVectPR;
selVectUD = selVectUD & ~selVectPR;
selVectLR = selVectLR & ~selVectPR;

% combined confusions are any non taken region or overlap between other confusions
selVectCB = ~(selVectPR | selVectFB | selVectUD | selVectLR);
selVectCB = selVectCB | (selVectFB & selVectUD) | (selVectFB & selVectLR) | (selVectUD & selVectLR);

% combined confusions wins over all confusions
selVectPR = selVectPR & ~selVectCB;
selVectFB = selVectFB & ~selVectCB;
selVectUD = selVectUD & ~selVectCB;
selVectLR = selVectLR & ~selVectCB;


%% (DISCARDED) simple method, 2 types of confusion: precision or combined. 
% combined if gc error > threshold, precision otherwise.

% case 'simple'
% 
% % init threshold
% angleThresh = 45; % in degree
% 
% % get great circle difference
% gc = getGreatCircleAngle(xyzTrue, xyzAnsw);
% 
% % precision
% selVectPR = abs(gc) <= angleThresh;
% 
% % combined
% selVectCB = ~selVectPR;
% 
% % remainder (dummies)
% selVectFB = false(length(gc), 1);
% selVectUD = selVectFB;
% selVectLR = selVectFB;


%% (DISCARDED) new method, based on sphere cartesian regions / quadrant

% case 'quadrant'
% 
% % init thresholds
% dist = 1;
% angleThresh = 45; % confusion angle threshold (in degree)
% distThresh = dist * sind(angleThresh);
% angleThresh2 = 20/2; % neutralBand angle threshold (in degree)
% distThresh2 = dist * sind(angleThresh2);
% 
% % force radius to "dist" and get cartesian difference (easier to determine confusions)
% distVect = dist * ones(size(xyzTrue, 1), 1);
% posSph = cart2sphVect( xyzTrue );
% xyzTrue = sph2cartVect( [posSph(:,1) posSph(:,2) distVect] );
% posSph = cart2sphVect( xyzAnsw );
% xyzAnsw = sph2cartVect( [posSph(:,1) posSph(:,2) distVect] );
% xyzDiff = abs( xyzAnsw - xyzTrue );
% 
% % front-back (x symmetry)
% selVectFB = xyzDiff(:,1) > distThresh;
% selVectFB = selVectFB & abs(xyzTrue(:,1)) > distThresh2 & abs(xyzAnsw(:,1)) > distThresh2;
% selVectFB = selVectFB & sign(xyzTrue(:,1)) ~= sign(xyzAnsw(:,1));
% 
% % left-right (y symmetry, beyond neutral band, on opposite side)
% selVectLR = xyzDiff(:,2) > distThresh;
% selVectLR = selVectLR & abs(xyzTrue(:,2)) > distThresh2 & abs(xyzAnsw(:,2)) > distThresh2;
% selVectLR = selVectLR & sign(xyzTrue(:,2)) ~= sign(xyzAnsw(:,2));
% 
% % up-down (z symmetry)
% selVectUD = xyzDiff(:,3) > distThresh;
% selVectUD = selVectUD & abs(xyzTrue(:,3)) > distThresh2 & abs(xyzAnsw(:,3)) > distThresh2;
% selVectUD = selVectUD & sign(xyzTrue(:,3)) ~= sign(xyzAnsw(:,3));
% 
% % precision is none of the above
% selVectPR = ~(selVectFB | selVectLR | selVectUD );
% % selVect0 = abs( interTrue(:,2) - interAnsw(:,2) ) <= angleThresh; % small polar angle diff
% % selVect0 = selVect0 & abs( interTrue(:,1) - interAnsw(:,1) ) <= angleThresh; % small lateral angle diff
% 
% % precision wins over all confusions
% selVectFB = selVectFB & ~selVectPR;
% selVectUD = selVectUD & ~selVectPR;
% selVectLR = selVectLR & ~selVectPR;
% 
% % combined
% selVectCB = (selVectFB & selVectUD) | (selVectFB & selVectLR) | (selVectUD & selVectLR);
% 
% % combine wins over all confusions
% selVectFB = selVectFB & ~selVectCB;
% selVectUD = selVectUD & ~selVectCB;
% selVectLR = selVectLR & ~selVectCB;


%% default is error

otherwise

error('undefined flagMethod: %s', flagMethod);

end

%% common to all methods

% output ids of confusion type
confType = nan(size(xyzTrue, 1),1);
confType(selVectPR) = 0;
confType(selVectFB) = 1;
confType(selVectUD) = 2;
confType(selVectLR) = 3;
confType(selVectCB) = 4;

% output strings of confusion type
confTypeStr = cell(size(confType));
confTypeStr(selVectPR) = {'precision'};
confTypeStr(selVectFB) = {'front-back'};
confTypeStr(selVectUD) = {'up-down'};
confTypeStr(selVectLR) = {'left-right'};
confTypeStr(selVectCB) = {'combined'};

%% sanity check 

% check underlap
if( any( isnan( confType ) ) )
    
    % print offensive lines
    posIds = find( isnan( confType ) );
    for iPos = 1:length(posIds)
        posId = posIds(iPos);
        fprintf('true: %.1f %.1f %.1f \t answ: %.1f %.1f %.1f \n-> pr: %d fb: %d ud: %d lr: %d cb: %d \n\n', ...
            interTrue(posId,1), interTrue(posId,2), interTrue(posId,3), ...
            interAnsw(posId,1), interAnsw(posId,2), interAnsw(posId,3), ...
            selVectPR(posId), selVectFB(posId), selVectUD(posId), selVectLR(posId), selVectCB(posId));
    end
    
    % report error
    error('some points are not processed');
end

% check overlap
if( any( (selVectPR + selVectFB + selVectUD + selVectLR + selVectCB) ~= 1 ) )
    
    % print offensive lines
    posIds = find( (selVectPR + selVectFB + selVectUD + selVectLR + selVectCB) ~= 1 );
    for iPos = 1:length(posIds)
        posId = posIds(iPos);
        fprintf('true: %.1f %.1f %.1f \t answ: %.1f %.1f %.1f \n-> pr: %d fb: %d ud: %d lr: %d cb: %d \n\n', ...
            interTrue(posId,1), interTrue(posId,2), interTrue(posId,3), ...
            interAnsw(posId,1), interAnsw(posId,2), interAnsw(posId,3), ...
            selVectPR(posId), selVectFB(posId), selVectUD(posId), selVectLR(posId), selVectCB(posId));
    end
    
    % report error
    error('over/under overlapping confusions'); 
end

return 


%% debug function: plot polar confusion zones

% create fake positions
n = 100000;
interTrue = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
interAnsw = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];

% iso-lateral angle (cleaner 2D plot)
lat = 40;
interTrue = [ lat * ones(n,1), 360*rand(n,1) - 90, ones(n,1) ];
interAnsw = [ lat * ones(n,1), 360*rand(n,1) - 90, ones(n,1) ];

% compute conf type
confType = getConfusionType(inter2cartVect(interTrue), inter2cartVect(interAnsw), 'zagala');

% plot interaural spawn vs hit
confTypeColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0];
cmap = confTypeColors(confType+1,:);
scatter(interTrue(:,2), interAnsw(:,2), 5, cmap, 'filled');

% format
axis equal
grid on
xticks(-90:45:270); yticks(-90:45:270);
xlabel('target polar angle (deg)');
ylabel('response polar angle (deg)');

title(sprintf('lateral angle (deg): %d', lat));

%% debug function: check confusions by types on 3D sphere

% create fake positions
n = 100000;
% interTrue = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
% interTrue = repmat([45 45 1], n, 1);
interTrue = repmat([45 0 1], n, 1);
xyzTrue = inter2cartVect(interTrue);

interAnsw = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
xyzAnsw = inter2cartVect( interAnsw );

% create confusion
% xyzAnsw = [ -xyzTrue(:,1), xyzTrue(:,2), xyzTrue(:,3) ] % front-back
% xyzAnsw = [ xyzTrue(:,1), xyzTrue(:,2), -xyzTrue(:,3) ] % up-down
% xyzAnsw = [ xyzTrue(:,1), -xyzTrue(:,2), xyzTrue(:,3) ] % left-right
% xyzAnsw = [ -xyzTrue(:,1), -xyzTrue(:,2), -xyzTrue(:,3) ] % combined

% compute conf type
confType = getConfusionType(xyzTrue, xyzAnsw, 'zagala');
% confType = getConfusionType(xyzTrue, xyzAnsw, 'poirier');

% plot interaural spawn vs hit
confTypeColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0];
% gray: precision, red: front-back, green: up-down, blue: left-right, black: combined

cmap = confTypeColors(confType+1,:);
scatter3(xyzAnsw(:,1), xyzAnsw(:,2), xyzAnsw(:,3), 6, cmap, 'filled', 'HandleVisibility', 'off');
hold on, 
scatter3(xyzTrue(:,1), xyzTrue(:,2), xyzTrue(:,3), 1000, [1 0 1], 'filled'); % source
scatter3(1, 0, 0, 1000, [0 1 1], 'filled'); % user forward
hold off

% format
xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
axis equal, rotate3d on, grid on, 
view([140 24]);
legend({'source', 'usr fwd'});
% view([180 0]);

title(sprintf('lateral angle (deg): %d', 60));

%% debug: find confusions that do not make sense when flagged with parseihian's method

% lateral
interTrue = [60 0 1];
interAnsw = [-60 180 1];

% lateral
interTrue = [45 5  1; 10 0   1];
interAnsw = [45 51 1; 95 0 1];

xyzTrue = inter2cartVect( interTrue );
xyzAnsw = inter2cartVect( interAnsw );

% compute conf type
% [confType, confTypeStr] = getConfusionType(xyzTrue, xyzAnsw, 'poirier'); 
[confType, confTypeStr] = getConfusionType(xyzTrue, xyzAnsw, 'parseihian');

% log
for iConf = 1:length(confTypeStr)
    fprintf('[%d, %d, %d] -> [%d %d %d]: %s \n', interTrue(iConf, :), interAnsw(iConf, :), confTypeStr{iConf});
end

return 

% plot
cmap = confTypeColors(confType+1,:);
scatter3(xyzAnsw(:,1), xyzAnsw(:,2), xyzAnsw(:,3), 300, cmap, 'filled', 'HandleVisibility', 'off');
hold on, 
scatter3(xyzTrue(:,1), xyzTrue(:,2), xyzTrue(:,3), 1000, [1 0 1], 'filled'); % source
scatter3(1, 0, 0, 1000, [0 1 1], 'filled'); % user forward
hold off

% add sphere
hold on
[X,Y,Z] = sphere(20);
surf(X, Y, Z, 'FaceAlpha', 0.7, 'FaceColor', 1*[1 1 1], 'EdgeColor', 0.7*[1 1 1]);
hold off,

% format
xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
xlim([-1 1]); ylim([-1 1]); zlim([-1 1]);
rotate3d on, grid on, axis equal
view([140 24]);
legend({'source', 'usr fwd'});

% view([180 0]);



