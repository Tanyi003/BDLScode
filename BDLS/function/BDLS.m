
function [model_BDLS,loss] = BDLS( X, Y, optmParameter)  
   %% optimization parameters
    alpha            = optmParameter.alpha;
    beta             = optmParameter.beta;
    lambda           = optmParameter.lambda;
    gamma            = optmParameter.gamma;
    maxIter          = optmParameter.maxIter;
    miniLossMargin   = optmParameter.minimumLossMargin;

   %% initializtion
    num_dim = size(X,2);
    XTX = X'*X;
    XTY = X'*Y;
    YTY = Y'*Y;
    W_s   = (XTX + gamma*eye(num_dim)) \ (XTY);
    W_s_1 = W_s;
        
    %%  DAG  
    data_type='dis';     
    % Name of algorithm
    alg_name='GSBN';
    % Significance level
    alpha2=0.01 ;
    [DAG,~]=Causal_Learner(alg_name,(Y+1),data_type,alpha2);
%     DAG=MB;
    sparse(DAG);
%     draw_graph(DAG);
    R = (DAG+DAG')/2;


    iter    = 1;
    oldloss = 0;
    
    Lip = sqrt(2*(norm(XTX)^2 + norm(alpha*R)^2 + norm(lambda*YTY)^2));

    bk = 1;
    bk_1 = 1; 
    
   %% proximal gradient
    while iter <= maxIter

       W_s_k  = W_s + (bk_1 - 1)/bk * (W_s - W_s_1);
       Gw_s_k = W_s_k - 1/Lip * ((XTX*W_s_k - XTY - lambda*XTY) + alpha * W_s_k*R + lambda * W_s_k*YTY);
       bk_1   = bk;
       bk     = (1 + sqrt(4*bk^2 + 1))/2;
       W_s_1  = W_s;
       W_s    = softthres(Gw_s_k,beta/Lip);
       
       predictionLoss = trace((X*W_s - Y)'*(X*W_s - Y));
       YLoss          = trace((Y*W_s' - X)'*(Y*W_s' - X));
       correlation     = trace(R*W_s'*W_s);
       sparsity    = sum(sum(W_s~=0));
       totalloss = predictionLoss + alpha*correlation + beta*sparsity + lambda*YLoss;
       loss(iter,1) = totalloss;
       if abs(oldloss - totalloss) <= miniLossMargin
           break;
       elseif totalloss <=0
           break;
       else
           oldloss = totalloss;
       end
       
       iter=iter+1;
    end
    model_BDLS = W_s;

end


%% soft thresholding operator
function W = softthres(W_t,lambda)
    W = max(W_t-lambda,0) - max(-W_t-lambda,0); 
end
