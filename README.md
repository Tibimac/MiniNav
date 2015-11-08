# MiniNav
Exercice "MiniNav" de la semaine 5 du MOOC "Programmation iPhone et iPad".<br/>
Réalisation : 05 juin 2014

- ARC désactivé.
- Structure MVC.
- Pas de storyboard.
- 2 UIToolBar pour permettre l'affichage de l'URL courante
- Gestion de l'URL saisi et verif avec l'URL courante pour réinitialiser le champ de la UIAlertView (contient "http://" par défaut pour en éviter la saisie à l'utilisateur).
- Gestion de la délégation sur le UITextField de la UIAlertView pour permettre la validation/disparition de la UIAlertView lorsqu'on appui sur la touche "retour" du clavier.
- Gestion de l'orientation et des iPhone, iPad sous iOS6 ou iOS7 avec un placement assez dynamique en relatif à la taille de la vue.
- Ajout d'un "observateur" lorsque la statusBar change de taille pour redimensionner la vue correctement et ne pas masquer la toolbar du bas
- Un spinner pendant les temps de chargement intégré dans une toolbar et gestion de l'activation/desactivation des boutons en fonction de la naviagation (ex:bouton home désactivé si on est sur la page d'accueil).
