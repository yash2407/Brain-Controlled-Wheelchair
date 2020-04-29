clear all;
clc;
filename=fullfile('testfile1.txt');
data=readtable(filename);
p = 0.8;
N = size(data,1);  % total number of rows 
tf = false(N,1);    % create logical index vector
tf(1:round(p*N)) = true;     
tf = tf(randperm(N));   % randomise order
dataTraining = data(tf,:) ;
dataTesting = data(~tf,:);
C=200;
x=dataTraining(:,1:4);
trainLabel=dataTraining(:,5);
test=dataTesting(:,1:4);
testLabel=dataTesting(:,5);
result=multisvm(x,trainLabel,test);
disp(result,testLabel);
