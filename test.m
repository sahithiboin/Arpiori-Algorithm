clc;
clear;
close all;

amazon = importdata('datab5.csv',',');

prompt='enter min supp as decimal e.g 0.2\n';
minSup=input(prompt); 

promp='enter min conf as decimal e.g 0.6\n';
minConf=input(promp); 
nRules = 100;
sortFlag = 1;
fname='associationrules';
labels= {'onions', 'apples', 'bread', 'sugar','salt', 'lays','shampoo', 'brush','coke','chicken'};


[Rules, FreqItemsets] = findRules(amazon, minSup, minConf, nRules, sortFlag, labels, fname);
disp(['For the association rules check the file named ' fname '.txt']);

