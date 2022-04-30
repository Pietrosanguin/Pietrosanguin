%% Genero i punti e li etichetto in base alla classe
%Codice utile per implementare un risultato simile a quello che voglio
%https://it.mathworks.com/matlabcentral/answers/461354-label-my-data-set-automatically-and-group-the-similar-points-or-the-nearest-points-with-the-same

%Ci sono due modi per generare i clusters: gaussianamente oppure tramite
%linkage, NB controllare il dendrogram (cluster con numeri casuali)

%provo con il linkage
%numero di punti casuali da generare
punti = 1000;

rng('default'); % For reproducibility

%coppie di punti con coordinate in 2d
X = [(randn(punti,2)*(0.75))+3;
    (randn(punti,2)*1)-2];

%etichettare casualmente il 3% dei dati
y = [ones(punti,1);-ones(punti,1)];
g=lab_mach(y);

gscatter(X(:,1),X(:,2),g);
grid on;
title('Randomly Generated Data');

%numero di punti etichettati
n_lab = sum(abs(g));

%Seleziono i dati in base alla classe di appartenenza
X_lab1 = X(g(:,1) == 1, : );
X_lab2 = X(g(:,1) == -1, : );
X_un = X(g(:,1) == 0, : );

y_lab1 = g(g(:,1) == 1, : );
y_lab2 = g(g(:,1) == -1, : );
y_un = g(g(:,1) == 0, : );

%unisco i dati labled in un unica matrice
X_lab = [X_lab1 ; X_lab2];

y_lab = [y_lab1 ; y_lab2];


%Considero come similarity measure la distanza euclidea (volendo si può
%cambiare in minkowski)

%distanza tra unlabeled e labeled
%w_ij = pdist2(X_lab(1,:),X_un(2,:));
w_ij = pdist2(X_lab,X_un);

%distanza tra i vari unlabeled 
w_bar_ij = pdist2(X_un,X_un);

%scrivo un ciclo for in cui itero itero in k ed aggiorno i gradienti
%la funzione GM_lab calcola il gradiente in funzione del vettore di
%instanze unlabeled
%grad = GM_Lab(y_un,y_lab,w_ij,w_bar_ij);

%calcolo il gradiente come prodotto tra matrici

 %for j= 1:length(y_un)
    %grad = transpose(2*transpose(y_un(j)-y_lab)*w_ij+2*transpose(y_un(j)-y_un)*w_bar_ij);
    
 %end 
 
 for j= 1:length(y_un)
     for i = 1:length(y_lab)
         for k= 1:length(y_un) 
         
    
             grad1(j) = (2*w_ij(i,j)*(y_un(j)-y_lab(i))+2*w_bar_ij(k,j)*(y_un(k)-y_un(j)));
         
         end
         
     end
 end

 grad = transpose(grad1);

%norma del gradiente
gnr = grad.'*grad;


%% Discesa del gradiente con alpha fissato
%Costante di Lipschitz e numero massimo di iterazioni
lc = 100;
alpha = 1/lc;
maxniter = 10000;

%contatore di iterazioni
it = 1;

%valore della funzione
sum1 = sum(w_ij*(y_un.^2))+(y_lab.^2).'*sum(w_ij,2)-2*y_lab.'*(w_ij*y_un);
sum2 = sum(w_bar_ij*(y_un.^2))+(y_un.^2).'*sum(w_bar_ij,2)-2*y_un.'*(w_bar_ij*y_un);

fx=sum1 + 0.5*sum2;   %nella notazione del prof è fx nel nostro caso sarebbe fy

stopcr = 2; %l'algoritmo si ferma quando il gradiente è vicino al minimo
verbosity =1; %scive gli update del gradiente se >0

while (1)
    
    if (it>=maxniter)
        break;
    end
    switch stopcr
            case 1
                % continue if not yet reached target value fstop
                if (fx<=fstop)
                    break
                end
            case 2
                % stopping criterion based on the product of the 
                % gradient with the direction
                if (abs(gnr) <= eps)
                    break;
                end
            otherwise
                error('Unknown stopping criterion');
    end % end of the stopping criteria switch
    
    d=-grad;
    gnr = grad'*d;
    gnrit(it) = -gnr;
    
            z=y_un+alpha*d;
            sum1z = sum(w_ij*(z.^2))+(y_lab.^2).'*sum(w_ij,2)-2*y_lab.'*(w_ij*z);
            sum2z = sum(w_bar_ij*(z.^2))+(z.^2).'*sum(w_bar_ij,2)-2*z.'*(w_bar_ij*z);
            fz=sum1z + 0.5*sum2z;
            
             
          for j= 1:length(z)
               for i = 1:length(y_lab)
                  for k= 1:length(z) 
         
    
                      grad1z(j) = (2*w_ij(i,j)*(z(j)-y_lab(i))+2*w_bar_ij(k,j)*(z(k)-z(j)));
         
                  end
         
               end
          end    
          
          gz = transpose(grad1z);
          
            %for j= 1:length(z)
            %gz = transpose(2*(z(j)-y_lab).'*w_ij+2*(z(j)-y_un).'*w_bar_ij);
            %end 
           
            
            if (verbosity>0)
            disp(['-----------------** ' num2str(it) ' **------------------']);
            disp(['gnr      = ' num2str(abs(gnr))]);
            disp(['f(x)     = ' num2str(fx)]);
            disp(['alpha     = ' num2str(alpha)]);                    
            end
        grad = gz; 
        y_un= z;
        it = it+1;
    
    
    
end

%% Inserisco i parametri per provare la funzione G_descent

% Optimality tolerance:
eps = 1.0e-4;
% Stopping criterion
%
% 1 : reach of a target value for the obj.func. fk - fstop <= eps
% 2 : nabla f(xk)'dk <= eps
stopcr = 2;

%verbosity =0 doesn't display info, verbosity =1 display info
verb=1;

%Valore della Lipschitz constant dato a caso, bisogna calcolarlo come
%massimo degli autovettori
lc = 100;

% starting point, sono gli unlabled
x1= y_un;

fstop = 0;
maxit = 10000;
arls=3;

disp('*****************');
disp('*  GM STANDARD  *');
disp('*****************');

%ygm è il vettore delle previsioni prodotte dal metodo (cioè il minimo
%della funzione a cui sono interesato
%itergm è il numero di iterazioni fatte dal metodo
[ygm,itergm,fxgm,tottimegm,fhgm,timeVecgm,gnrgm]=...
G_descent(w_ij,y_lab,w_bar_ij,y_un,lc,verb,arls,maxit,eps,fstop,stopcr);



% Print results:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'0.5*xQX - cx  = %10.3e\n',fxgm);
%fprintf(1,'Number of non-zero components of x = %d\n',...
%   sum((abs(xgm)>=0.000001)));
fprintf(1,'Number of iterations = %d\n',itergm);
fprintf(1,'||gr||^2 = %d\n',gnrgm(maxit));
fprintf(1,'CPU time so far = %10.3e\n', tottimegm);


