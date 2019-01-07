function recordMtx = recordMatrix(records) 

recordMtx = records(3,:);
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(records{3,1}),size(records,2)]);
recordMtx = double(recordMtx');

end