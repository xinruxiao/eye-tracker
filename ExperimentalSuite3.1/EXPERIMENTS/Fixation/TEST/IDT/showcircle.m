function [] = showcircle( x,y)  


dt=DelaunayTri(x,y)
%=delaunayTriangulation(x,y)
k = convexHull(dt);
plot(x,y, '.', 'markersize',10); hold on;
plot(x(k), y(k), 'r'); hold off;

end