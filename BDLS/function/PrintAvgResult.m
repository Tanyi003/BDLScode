function [Avg_Result, AverageRunningTime] = PrintAvgResult(Result, time, num_cv)
% print the results of multi-label classification


    AverageRunningTime = mean(time);
    Avg_Result = zeros(16,2);
    cvResult = zeros(16,num_cv);
    tags = cell(1,1);

    for j = 1:num_cv
        cvResult(:,j) = Result{j}(:,1);
    end
    Avg_Result(:,1)=mean(cvResult,2);
    Avg_Result(:,2)=std(cvResult,1,2);
    tags{1,1} = 'MW2L';
    
    PrintResultsAll(Avg_Result,tags);
    fprintf('--------------------------------------------\n');
    fprintf('MW2L Avg Running Time: %f s\n',AverageRunningTime);
    fprintf('--------------------------------------------\n');

end