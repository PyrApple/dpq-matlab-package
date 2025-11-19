function [] = resize(wh)
    
    xywh = get(gcf, 'position');
    set(gcf, 'position', [xywh(1:2) wh(1) wh(2)]);

end