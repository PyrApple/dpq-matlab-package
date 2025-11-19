function [] = save( filePath )
    
    % saveas(gcf, filePath);

    % crops image border
    exportgraphics(gca, filePath, 'ContentType', 'image');
    fprintf('save %s \n', filePath);

end