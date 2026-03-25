function y = db20(in)
y = db(abs(in)/max(abs(in(:))));
