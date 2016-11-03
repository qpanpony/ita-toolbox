function d = get_distances(x,y)
% calculate euclidean distances quickly

%% check input data
sz_x = size(x);
sz_y = size(y);

if numel(sz_x) > 2 || numel(sz_y) > 2
    error('only matrix or vector input allowed')
end

if sz_x(2) ~= 3
    if sz_x(1) == 3 % transform
        x = x.';
    else
        error('wrong dimensions for x input');
    end
end

if sz_y(2) ~= 3
    if sz_y(1) == 3 % transform
        y = y.';
    else
        error('wrong dimensions for y input');
    end
end

%% calculate norm(x-y)
d = sqrt(bsxfun(@plus,sum(abs(x).^2,2),sum(abs(y).^2,2).') - 2.*x*y.');

end % function