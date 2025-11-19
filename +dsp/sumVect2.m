function out = sumVect2(x1, x2)
    
% Sum content of vectors x1 and x2
% 
% out = sumVect2(x1, x2)
% 
% x1 is N1xM1, x2 is N2xM2, out dimension is adjusted to greatest values,
% padding with zeros: out is max(N1,N2)xmax(M1,M2)

% adjust size dimension 1 (samples)
if(size(x1, 1) < size(x2, 1))
    x1 = [ x1; zeros(size(x2, 1) - size(x1, 1), size(x1, 2)) ];

elseif(size(x2, 1) < size(x1, 1))
    x2 = [ x2; zeros(size(x1, 1) - size(x2, 1), size(x2, 2)) ];
end

% adjust size dimension 2 (channels)
if(size(x1, 2) < size(x2, 2))
    x1 = [ x1, zeros(size(x1, 1), size(x2, 2) - size(x1, 2)) ];
    
elseif(size(x2, 2) < size(x1, 2))
    x2 = [ x2, zeros(size(x2, 1), size(x1, 2) - size(x2, 2)) ];
end

% sum 
out = x1+x2;

end