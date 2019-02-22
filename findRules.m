function [Rules FreqItemsets] = findRules(transactions, minSup, minConf, nRules, sortFlag, labels, fname)

T1 = size(transactions,1);
T2 = size(transactions,2);

if nargin < 7
    fname = 'default';
end

if nargin < 6
    labels = cellfun(@(x){num2str(x)}, num2cell(1:T2));
end

if nargin < 5
    sortFlag = 1;
end

if nargin < 4
    nRules = 100;
end

if nargin < 3
    minConf = 0.5;
end

if nargin < 2
    minSup = 0.5;
end

if nargin == 0
    error('No input arguments were supplied.  At least one is expected.');
end

maxSize = 10^2;
Rules = cell(2,1);
Rules{1} = cell(nRules,1);
Rules{2} = cell(nRules,1);
FreqItemsets = cell(maxSize);
RuleConf = zeros(nRules,1);
RuleSup = zeros(nRules,1);
ct = 1;

M = [];
for i = 1:T2
    S = sum(transactions(:,i))/T1;
    if S >= minSup
        M = [M; i];
    end
end
FreqItemsets{1} = M;

for steps = 2:T2
    
    U = unique(M);
    if isempty(U) || size(U,1) == 1
        Rules{1}(ct:end) = [];
        Rules{2}(ct:end) = [];
        FreqItemsets(steps-1:end) = [];
        break
    end
    
    Combinations = nchoosek(U',steps);
    TOld = M;
    M = [];
    
    for j = 1:size(Combinations,1)
        if ct > nRules
            break;
        else
            if sum(ismember(nchoosek(Combinations(j,:),steps-1),TOld,'rows')) - steps+1>0
                
           
                S = mean((sum(transactions(:,Combinations(j,:)),2)-steps)>=0);
                if S >= minSup
                    M = [M; Combinations(j,:)];
                    
                  
                    for depth = 1:steps-1
                        R = nchoosek(Combinations(j,:),depth);
                        for r = 1:size(R,1)
                            if ct > nRules
                                break;
                            else
                                
                                Ctemp = S/mean((sum(transactions(:,R(r,:)),2)-depth)==0);
                                if Ctemp > minConf
                                    
                                   
                                    Rules{1}{ct} = R(r,:);
                                    Rules{2}{ct} = setdiff(Combinations(j,:),R(r,:));
                                    RuleConf(ct) = Ctemp;
                                    RuleSup(ct) = S;
                                    ct = ct+1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
   
    FreqItemsets{steps} = M;
end


FreqItemsets(steps-1:end) = [];
RuleConf = RuleConf(1:ct-1);
RuleSup = RuleSup(1:ct-1);


switch sortFlag
    case 1
        [V ind] = sort(RuleSup,'descend');
    case 2
        [V ind] = sort(RuleConf,'descend');
end

RuleConf = RuleConf(ind);
RuleSup = RuleSup(ind);

for i = 1:2
    temp = Rules{i,1};
    temp = temp(ind);
    Rules{i,1} = temp;
end



fid = fopen([fname '.txt'], 'w');
fprintf(fid, '%s   (%s, %s) \n', 'Rule', 'Support', 'Confidence');

for i = 1:size(Rules{1},1)
    s1 = '';
    s2 = '';
    for j = 1:size(Rules{1}{i},2)
        if j == size(Rules{1}{i},2)
            s1 = [s1 labels{Rules{1}{i}(j)}];
        else
            s1 = [s1 labels{Rules{1}{i}(j)} ','];
        end
    end
    for k = 1:size(Rules{2}{i},2)
        if k == size(Rules{2}{i},2)
            s2 = [s2 labels{Rules{2}{i}(k)}];
        else
            s2 = [s2 labels{Rules{2}{i}(k)} ','];
        end
    end
    s3 = num2str(RuleSup(i)*100);
    s4 = num2str(RuleConf(i)*100);
    fprintf(fid, '%s -> %s  (%s%%, %s%%)\n', s1, s2, s3, s4);
end
fclose(fid);
end