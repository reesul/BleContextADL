function [] = dispClusterOcc(cluster, oMap)

for i=1:length(cluster)
    disp(cluster(i))
    disp(oMap(cluster(i)))
end
