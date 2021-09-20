close all
clear all;

d = 'E:\FILE DARI DOCUMENT LAPTOP BARU\CODING MATLAB\faster rcnn\newAlexnet_nexLevel';
imds = imageDatastore(fullfile(d),...
'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');

%%% preprocess
%net = alexnet;
%inputSize = net.Layers(1).InputSize(1:2);

% Set the ImageDatastore ReadFcn
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

[trainingSet, testSet] = splitEachLabel(imds, 0.9);

%%%convert trainingSet to vector training images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numTrainImages = numel(trainingSet.Labels);
trainingImages=zeros(227,227,3,numTrainImages);
for i = 1:numTrainImages 
    I = readimage(trainingSet,i);
    trainingImages(:,:,:,i)=I;
    %imshow(I)
end
trainingImages=uint8(trainingImages);
trainingLabels=trainingSet.Labels;

numTestImages = numel(testSet.Labels);
testImages=zeros(227,227,3,numTestImages);
for i = 1:numTestImages 
    I = readimage(testSet,i);
    testImages(:,:,:,i)=I;
    %imshow(I)
end
testImages=uint8(testImages);
testLabels=testSet.Labels;

numImageCategories = 4;

%%
% Load a pretrained AlexNet network.
net = alexnet;

%%
% The last three layers of the pretrained network |net| are configured for
% 1000 classes. These three layers must be fine-tuned for the new
% classification problem. Extract all the layers except the last three from
% the pretrained network, |net|.
layersTransfer = net.Layers(1:end-4);

%%
% Transfer the layers to the new task by replacing the last three layers
% with a fully connected layer, a softmax layer, and a classification
% output layer. Specify the options of the new fully connected layer
% according to the new data. Set the fully connected layer to be of the
% same size as the number of classes in the new data. To speed up training,
% also increase |'WeightLearnRateFactor'| and |'BiasLearnRateFactor'|
% values in the fully connected layer.

%%
% Determine the number of classes from the training data.
numClasses = 4;

%%
% Create the layer array by combining the transferred layers with the new
% layers.
layers = [...
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%%
% If the training images differ in size from the image input layer, then
% you must resize or crop the image data. The images in |merchImages| are
% the same size as the input size of AlexNet, so you do not need to resize
% or crop the new image data.

%%
% Create the training options. For transfer learning, you want to keep the
% features from the early layers of the pretrained network (the transferred
% layer weights). Set |'InitialLearnRate'| to a low value. This low initial
% learn rate slows down learning on the transferred layers. In the previous
% step, you set the learn rate factors for the fully connected layer higher
% to speed up learning on the new final layers. This combination results in
% fast learning only on the new layers, while keeping the other layers
% fixed. When performing transfer learning, you do not need to train for as
% many epochs. To speed up training, you can reduce the value of the
% |'MaxEpochs'| name-value pair argument in the call to |trainingOptions|.
% To reduce memory usage, reduce |'MiniBatchSize'|.
options = trainingOptions('sgdm',...
    'MiniBatchSize',32,...
    'MaxEpochs',40,...
    'InitialLearnRate',0.0001,'OutputFcn',@plotTrainingAccuracy);
%%
% Train the network using the |trainNetwork| function. This is a
% computationally intensive process that takes 20-30 minutes to complete.
% To save time while running this example, a pre-trained network is loaded
% from disk. If you wish to train the network yourself, set the
% |doTraining| variable shown below to true.
%
% Note that a CUDA-capable NVIDIA(TM) GPU with compute capability 3.0 or
% higher is highly recommeded for training.

% A trained network is loaded from disk to save time when running the
% example. Set this flag to true to train the network.
doTraining = true;

if doTraining    
    % Train a network.
    myNet = trainNetwork(trainingImages, trainingLabels, layers, options);
else
    % Load pre-trained detector for the example.
    load('mynet.mat','myNet')       
end



% Run the network on the test set.
YTest = classify(myNet, testImages);
% Calculate the accuracy.
accuracy = sum(YTest == testLabels)/numel(testLabels)

%%
% Use the custom function |plotTrainingAccuracy| to plot
% |info.TrainingAccuracy| against |info.Iteration| at each function call.

function plotTrainingAccuracy(info)

persistent plotObj

if info.State == "start"
    plotObj = animatedline;
    xlabel("Iteration")
    ylabel("Training Accuracy")
elseif info.State == "iteration"
    addpoints(plotObj,info.Iteration,info.TrainingAccuracy)
    drawnow limitrate nocallbacks
end

end