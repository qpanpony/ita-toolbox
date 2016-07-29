function x = test_steepest_descend(this, SYNTH, SPEAK, input)

j = sqrt(-1);
nIt = 10;
x = SYNTH*input;
dA = mean(abs(x))*0.1;
mu = 1e-4;

pen = zeros(nIt+1,1);

A = SYNTH*input;
B = (eye(this.nApertures) - SYNTH*SPEAK);
for idxI = 1:nIt
    pen(idxI) = penalty(x);
    
    dPen = zeros(length(x),1);
    for idxX = 1:length(x)
        dX = zeros(length(x),1); dX(idxX) = dA;
        testX = A + B * (abs(x) + dX) * exp(j*mean(angle(x)));
        dPen(idxX) = (penalty(testX) - pen(idxI))/dA;
    end
    x = A + B * (abs(x) - mu*dPen) * exp(j*mean(angle(x)));
    plot(pen); pause(0.05);
end

 

end
function pen = penalty(x)
pen = std(angle(x));
end