function [cellAngles, cellShapeIndices] = getSphereVoronoiAngles(aed)
        
    % sanity check
    if( size(aed, 2) ~= 3 ); error('expected Nx3 vector'); end
    if( any( (aed(:, 3) - aed(1, 3)) > 1e-3 ) ); error('expected constant radius'); end
        
    % radius (required by voronoisphere)
    aed(:, 3) = ones(size(aed, 1), 1);
    
    % sph to cart
    xyz = sph2cartVect(aed);
        
	% compute spherical voronoi
    [vertices_xyz, cells, voronoiboundary, cellAngles] = voronoisphere(xyz.');
    vertices_xyz = vertices_xyz.';
    
    % rad 2 deg
    cellAngles = rad2deg(cellAngles);
    
    % loop over cells
    cellPerimeters = nan(length(cells), 1);
    for iCell = 1:length(cells)

        % select cell vertices
        v_xyz = vertices_xyz(cells{iCell}, :);

        % discard if empty
        if isempty(v_xyz); continue; end

        % close cell
        v_xyz = v_xyz([1:end 1], :);

        % loop over vertices
        p = 0;
        for iPoint = 1:(size(v_xyz, 1)-1)
            p = p + getGreatCircleAngle(v_xyz(iPoint+1, :), v_xyz(iPoint, :));
        end
        
        % save to locals
        cellPerimeters(iCell) = p;
    end
    
    % compute shape indice (4*180 for normalisation in 0-1)
    cellShapeIndices = (4*180) * cellAngles ./ (cellPerimeters.^2);
    
    if( any( cellShapeIndices > 1 ) )
        warning('clipping shape indices to 1 (max value %.1f) due to method imprecision', max(cellShapeIndices));
        cellShapeIndices = min(cellShapeIndices, 1);
    end
    
    % % cart to geodesic
    % vertices_aed = cart2sphVect(vertices_xyz);
    % vertices_geo = [vertices_aed(:, 2), vertices_aed(:, 1)];
    % 
    % % compute area of each cell
    % cellAreas = nan(length(cells), 1);
    % for iCell = 1:length(cells)
    % 
    %     % select cell vertices
    %     v_geo = vertices_geo(cells{iCell}, :);
    % 
    %     % compute area
    %     % cellAreas(iCell) = polyarea(v_aed(:, 1), v_aed(:, 2)); % on plane
    %     cellAreas(iCell) = areaint(v_geo(:, 1), v_geo(:, 2)); % on sphere
    % end
    
    % debug plot
    if( false )
        
        % shape data
        voronoiboundary = cellfun(@(x) x.', voronoiboundary, 'UniformOutput', false);
        
        % plot original grid
        plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
        hold on
        
        % plot voronoi vertices
        plot3(vertices_xyz(:,1), vertices_xyz(:,2), vertices_xyz(:,3), 'w.', 'MarkerSize', 12);
        

        % plot voronoi edges
        for iCell = 1:length(cells)

            % select cell vertices
            v_xyz = vertices_xyz(cells{iCell}, :);

            % discard if empty
            if isempty(v_xyz); continue; end

            % close cell
            v_xyz = v_xyz([1:end 1], :);

            % loop over vertices, plot
            for i=1:size(v_xyz, 1)-1
                plot3(v_xyz(i:i+1, 1), v_xyz(i:i+1, 2), v_xyz(i:i+1, 3), 'Color', 0.5*[1 1 1], 'Linewidth', 1);
            end

        end

        % display area value
        aedTmp = aed; aedTmp(:,3) = 1.1*aedTmp(:,3);
        xyzTmp = sph2cartVect(aedTmp);
        for iCell = 1:length(cells)
            text(xyzTmp(iCell,1), xyzTmp(iCell,2), xyzTmp(iCell,3), sprintf('%.0f°', cellAngles(iCell)), 'Interpreter', 'none' );
        end
            
        % color cells based on ... value
        cmap = cool(16); 
        % cmap = flipud(cmap);
        for iCell = 1:length(cells)
            boundary = voronoiboundary{iCell};
            % colorId = floor( size(cmap, 1) * (cellAngles(iCell) / max(cellAngles)) );
            colorId = floor( size(cmap, 1) * cellShapeIndices(iCell) );
            colorId = max(1, colorId);
            cl = cmap(colorId,:);
            fill3(boundary(:,1),boundary(:,2),boundary(:,3),cl, 'EdgeColor','w');
        end
        
        % format: colorbar
        set(gcf,'Colormap',cmap);
        colorbar;
        
        
        % format
        hold off,
        axis('equal');
        grid on,
        rotate3d on,
        title({ ...
            sprintf('cell angle = %.1f +/- %.1f deg', mean(cellAngles), std(cellAngles)), ...
            sprintf('shape ind. %.1f +/- %.2f', mean(cellShapeIndices), std(cellShapeIndices))});
        % axis(ax,[-1 1 -1 1 -1 1]);
    
    end
    
    return 
    
    
    %% debug plot
    
    gridType = 4;
    
    switch gridType
        
        case 1
            
            % define grid: regular
            n = 25;
            xyz = getUniformSphereGrid(n);
            aed = cart2sphVect(xyz);
    
        case 2
            
            % define grid: random
            n = 25;
            xyz = rand(n, 3)-0.5;
            aed = cart2sphVect(xyz);
            aed(:,3) = ones(n, 1);
            % xyz = sph2cartVect(aed);
    
        case 3
            
            % define grid: manual regular
            azim = (-180+15):45:(180-15); elev = -45:45:45;
            n = length(azim); 
            % azim = wrapTo180(azim + 5);
            azim = repmat(azim, 1, length(elev)).';
            tmp = repmat(elev, n, 1); elev = tmp(:);
            aed = [azim, elev, ones(length(elev), 1)];
    
        case 4
            
            % define grid: equator
            n = 20;
            aed = [linspace(0, 360, n).' 5*rand(n, 1), ones(n, 1)];
    
        otherwise 
            error('undefined');
    end
    
    % debug
    selVect = contains(s2.experimentStr, 'stead');
    xyz = unique(s2.spawnCorrected(selVect, :), 'rows');
    aed = cart2sphVect(xyz);
    n = size(xyz, 1);

    % compute cell areas
    [cellAngles, cellShapeIndices] = getSphereVoronoiAngles(aed);
    
    % plot cell statistics
%     plot(cellShapeIndices)
    histogram(cellShapeIndices)
%     histogram(cellShapeIndices, 12);
%     xlim([0 360]); ylim([0 n]);
    
    
        
    
end























