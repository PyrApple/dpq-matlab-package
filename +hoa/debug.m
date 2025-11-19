in = rand(100, 16);

out1 = dpq.hoa.catt2ambix(in);
out2 = dpq.hoa.catt2ambix_eac(in);

surf(out1-out2);