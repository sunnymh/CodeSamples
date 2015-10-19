mkdir plots
plots_path = './plots/';

%%%%%%%%%%%%
% (1)
%%%%%%%%%%%%

% Preprocess images
image_size = [256 256];
image_length = 256*256;
face_image_path = './face_data/face/';
face_image_files = dir('./face_data/face/*.bmp');

all_faces = zeros(size(face_image_files, 1), image_length);
for i=1:size(face_image_files, 1),
   path = strcat([face_image_path, face_image_files(i).name]);
   all_faces(i,:) = double(reshape(imread(path), 1, image_length));
end

faces_training = all_faces(1:150, :);
faces_testing = all_faces(151:end, :);

% get mean face
faces_training_mean = mean(faces_training);
imwrite(get_image(faces_training_mean, image_size), strcat([plots_path, 'mean_face.bmp']));

% get eignvectors
faces_to_PCA = faces_training - ones(150, 1) * faces_training_mean;

[eigs_small, eigenvalues] = eig(faces_to_PCA * faces_to_PCA');
[tem, order] = sort(diag(eigenvalues), 'descend');
eigs_full = faces_to_PCA' * eigs_small(:,order);
eigenvalues_face_full = eigenvalues(order, order);

% plot eignvectors
for i=1:20,
    image = get_image(eigs_full(:,i)' + faces_training_mean, image_size);
    imwrite(image, strcat([plots_path, 'eignface_', num2str(i), '.bmp']));
end

% get reconstruction error
faces_to_test = faces_testing - ones(27, 1) * faces_training_mean;
reconstruct_errs = zeros(27, 20);
for i = 1:27,
    [im_vec, err] = reconstruct_image(faces_to_test(i,:), eigs_full(:, 1:20));
    reconstruct_errs(i, :) = err/image_length;  
    image = get_image(im_vec + faces_training_mean, image_size);
    imwrite(image, strcat([plots_path, 'reconstruct', num2str(i), '.bmp']));
end

figure1 = figure('visible','off');
plot(mean(reconstruct_errs), '-b');
title('Reconstruction errors for faces');
xlabel('k');
ylabel('Avg reconst err/pt');
print(figure1, '-dbmp', strcat([plots_path, 'part1.bmp']), '-r50');

%%%%%%%%%%%%%%
% (2)
%%%%%%%%%%%%%%

% Preprocess landmark
landmark_size = [87 2];
landmark_length = 87*2;
landmark_path = './face_data/landmark_87/';
landmark_files = dir('./face_data/landmark_87/*.dat');

all_landmarks = zeros(size(landmark_files, 1), landmark_length);
for i=1:size(landmark_files, 1),
   path = strcat([landmark_path, landmark_files(i).name]);
   data = importdata(path, ' ', 1);
   all_landmarks(i,:) = 255 - double(reshape(data.data, 1, landmark_length));
end

landmarks_training = all_landmarks(1:150, :);
landmarks_testing = all_landmarks(151:end, :);

% get mean landmark
landmarks_training_mean = mean(landmarks_training);
landmark = get_landmark(landmarks_training_mean, landmark_size);
figure2 = figure('visible','off');
plot(landmark(:,1), landmark(:,2), 'bo');
xlim([0,255]);
ylim([0,255]);
title('Mean landmark');
print(figure2, '-dbmp', strcat([plots_path, 'mean_landmark.bmp']), '-r50');

% get eignvectors
landmarks_to_PCA = landmarks_training - ones(150, 1) * landmarks_training_mean;

[eigs_small_landmarks, eigenvalues_landmarks] = eig(landmarks_to_PCA * landmarks_to_PCA');
[tem2, order] = sort(diag(eigenvalues), 'descend');
eigs_full_landmarks = landmarks_to_PCA' * eigs_small_landmarks(:,order);
eigenvalues_landmark_full = eigenvalues_landmarks(order, order);

% plot eignvectors
for i=1:5,
    figure3 = figure('visible','off');
    image = get_landmark(eigs_full_landmarks(:,i)' + landmarks_training_mean, landmark_size);
    plot(image(:,1), landmark(:,2), 'bo');
    xlim([0,255]);
    ylim([0,255]);
    title(strcat(['eigen wrapping ', num2str(i)]));
    print(figure3, '-dbmp', strcat([plots_path, 'eignwrap_', num2str(i), '.bmp']), '-r50');
end

% get reconstruction error
landmarks_to_test = landmarks_testing - ones(27, 1) * landmarks_training_mean;
landmarks_reconstruct_errs = zeros(27, 5);
for i = 1:27,
    [im_vec, err] = reconstruct_image(landmarks_to_test(i,:), eigs_full_landmarks(:, 1:5));
    landmarks_reconstruct_errs(i, :) = err.^0.5;  
    figure4 = figure('visible','off');
    image = get_landmark(im_vec + landmarks_training_mean, landmark_size);
    plot(image(:,1), landmark(:,2), 'bo');
    print(figure4, '-dbmp',strcat([plots_path, 'reconstruct_wrapping_', num2str(i), '.bmp']), '-r50');
end

figure5 = figure('visible','off');
plot(mean(landmarks_reconstruct_errs), '-b');
title('Reconstructed error for wrappings');
xlabel('k');
ylabel('Avg reconst err(distance)');

print(figure5, '-dbmp', strcat([plots_path, 'part2.bmp']), '-r50');

%%%%%%%%%%%%%%%
% (3) 
%%%%%%%%%%%%%%%
warpped_training_images = zeros(150, image_length);
for i=1:150,
    warpped_training_images(i,:) = double(reshape(warpImage_new( faces_training(i,:), get_landmark(landmarks_training(i,:), landmark_size), get_landmark(landmarks_training_mean, landmark_size)), 1, image_length));
end

% get mean face
faces_training_warpped_mean = mean(warpped_training_images);
imwrite(get_image(faces_training_mean, image_size), strcat([plots_path, 'mean_warpped_face.bmp']));

% get eignvectors
faces_warpped_to_PCA = warpped_training_images - ones(150, 1) * faces_training_warpped_mean;

[eigs_small, eigenvalues] = eig(faces_warpped_to_PCA * faces_warpped_to_PCA');
[tem, order] = sort(diag(eigenvalues), 'descend');
eigs_wrapped_full = faces_to_PCA' * eigs_small(:,order);
eigenvalues_face_warpped_full = eigenvalues(order, order);

reconstructed_err_wrapped = zeros(27,150);

for i=1:27,
    %(i)
    current_landmark = landmarks_testing(i,:) - landmarks_training_mean;
    original_mark = get_landmark(landmarks_testing(i,:), landmark_size);
    projected_landmark = project_image(current_landmark, eigs_full_landmarks(:, 1:10));
    desired_mark = get_landmark(projected_landmark + landmarks_training_mean, landmark_size);
    
    %figure;
    %plot(original_mark{1,1}, original_mark{1,2}, 'bo');
    %hold on;
    %old_mark = get_landmark(landmarks_training(1,:), landmark_size);
    %plot(old_mark{1,1}, old_mark{1,2}, 'ro');
    %hold off;
    
    current_image = double(reshape(warpImage_new( faces_testing(i,:), original_mark, get_landmark(landmarks_training_mean, landmark_size)), 1, image_length));

    for k=1:150,
        disp(strcat(['i: ', num2str(i), ', k: ', num2str(k)]));
        %(ii)
        projected_image = project_image(current_image-faces_training_warpped_mean, eigs_wrapped_full(:, 1:k));
        original_image = get_image(projected_image + faces_training_warpped_mean, image_size);
        
        %imshow(original_image);
        
        %(iii)
        wrapped_image = warpImage_new(original_image, get_landmark(landmarks_training_mean, landmark_size), desired_mark);
        
        %(iv)
        reconstructed_err_wrapped(i, k) = sum((double(reshape( wrapped_image, 1, image_length)) - faces_testing(i,:)).^2)/image_length;
    end
end

figure6 = figure('visible','off');
plot(mean(reconstructed_err_wrapped), '-b');
title('Reconstructed error for wrapped images');
xlabel('k');
ylabel('Avg reconst err/pt');
print(figure6, '-dbmp', strcat([plots_path, 'part3.bmp']), '-r50');


%%%%%%%%%%%%
% (4)
%%%%%%%%%%%%
randn(0);
original_landmark = get_landmark(landmarks_training_mean, landmark_size);

for i=1:20,
    disp(num2str(i));
    random_weight_faces = mvnrnd(zeros(10,1), eigenvalues_face_warpped_full(1:10, 1:10));
    random_intensity_faces = random_weight_faces / sum(abs(random_weight_faces));
    random_face = sum(eigs_wrapped_full(:,1:10) * diag(random_intensity_faces), 2)' + faces_training_warpped_mean;
    image = get_image(random_face, image_size);
    
    random_weight_landmarks = mvnrnd(zeros(10,1), eigenvalues_landmark_full(1:10, 1:10));
    random_intensity_landmarks = random_weight_landmarks / sum(abs(random_weight_landmarks));
    random_landmark = sum(eigs_full_landmarks(:,1:10) * diag(random_intensity_landmarks), 2)' + landmarks_training_mean;
    desired_wrapping = get_landmark(random_landmark, landmark_size);
    
    %figure;
    %plot(desired_wrapping(:,1), desired_wrapping(:,2), 'bo');
    
    synthesize_image = warpImage_new(image,original_landmark, desired_wrapping);    
    imwrite(synthesize_image, strcat([plots_path, 'synthesize_', num2str(i), '.bmp']));
end

%%%%%%%%%%%%%%%
% (5)
%%%%%%%%%%%%%%%
female_face_path = './face_data/female_face/';
female_face_files = dir('./face_data/female_face/*.bmp');

female_landmark_path = './face_data/female_landmark_87/';
female_landmark_files = dir('./face_data/female_landmark_87/*.txt');

male_face_path = './face_data/male_face/';
male_face_files = dir('./face_data/male_face/*.bmp');

male_landmark_path = './face_data/male_landmark_87/';
male_landmark_files = dir('./face_data/male_landmark_87/*.txt');

female_faces = zeros(size(female_face_files, 1), image_length);
for i=1:size(female_face_files, 1),
   path = strcat([female_face_path, female_face_files(i).name]);
   female_faces(i,:) = double(reshape(imread(path), 1, image_length));
end

female_landmarks = zeros(size(female_landmark_files, 1), landmark_length);
for i=1:size(female_landmark_files, 1),
   path = strcat([female_landmark_path, female_landmark_files(i).name]);
   data = importdata(path, ' ', 0);
   female_landmarks(i,:) = 255 - double(reshape(data, 1, landmark_length));
end

male_faces = zeros(size(male_face_files, 1), image_length);
for i=1:size(male_face_files, 1),
   path = strcat([male_face_path, male_face_files(i).name]);
   male_faces(i,:) = double(reshape(imread(path), 1, image_length));
end

male_landmarks = zeros(size(male_landmark_files, 1), landmark_length);
for i=1:size(male_landmark_files, 1),
   path = strcat([male_landmark_path, male_landmark_files(i).name]);
   data = importdata(path, ' ', 0);
   male_landmarks(i,:) = 255 - double(reshape(data, 1, landmark_length));
end

female_training = [female_faces(1:75,:) female_landmarks(1:75,:)];
male_training = [male_faces(1:78,:) male_landmarks(1:78,:)];
gender_testing = [female_faces(76:85,:) female_landmarks(76:85,:);male_faces(79:88,:) male_landmarks(79:88,:)];

Mf = mean(female_training);
Mm = mean(male_training);

C = [female_training;male_training]';

result = gender_testing * get_w(C, (Mf - Mm)');

figure7 = figure('visible','off');
plot(zeros(1, 10), result(1:10), 'r+');
hold on;
plot(zeros(1,10), result(11:20), 'bo')
plot([-5, 5], [0, 0], 'g-');
title('classification on test set');
print(figure7, '-dbmp', strcat([plots_path, 'part5.bmp']), '-r50');


%%%%%%%%%%%
% 6
%%%%%%%%%%%
Mf_shape = mean(female_landmarks(1:75,:));
Mm_shape = mean(male_landmarks(1:78,:));
C_shape = [female_landmarks(1:75,:);male_landmarks(1:78,:)]';
result_shape = [female_landmarks(76:85,:);male_landmarks(79:88,:)] * get_w(C_shape, (Mf_shape -Mm_shape)');

Mf_app = mean(female_faces(1:75,:));
Mm_app = mean(male_faces(1:75,:));
C_app = [female_faces(1:75,:);male_faces(1:78,:)]';
result_app = [female_faces(76:85,:);male_faces(79:88,:)] * get_w(C_app, (Mf_app -Mm_app)');

figure8 = figure('visible','off');
plot(result_shape(1:10), result_app(1:10), 'r+');
hold on;
plot(result_shape(11:20), result_app(11:20), 'bo');
plot([-0.08, 0.06], [0.018, -0.005], 'g-');
title('classification on test set');
print(figure8, '-dbmp', strcat([plots_path, 'part6.bmp']), '-r50');

