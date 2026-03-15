# Dépôt modèle pour le cours BIO 2045
# Devoir 2 - Succession végétale

## Table de matière du programme

### I. Introduction
- Présentation générale de la situation
- Problématique 
- Hypothèse
- Résultats attendus

### II. Présentation du modèle 
### III. Implémentation 

### IV. Code 
- Les packages necessaire 
- Les fonctions utilisés
- Les simulations 
- Représentation graphique

### V. Principeaux résultats 
### VI. Discussion
### VII. Conclusion 
- Résumés des résultats important
- Réponse à la problématique de l'introduction


## But du programme 

Simuler l'évolution de la végétalisation d'un terrain fraichement dégagé pour l'installation d'une ligne à haute tension. 
À la fin de la simulation, le modèle permettrait l'obtension d'une distribution végétale respectant un équilibre entre biodiversité et sécurité des infrastructures.

## Résumé
Pour atteindre l'objectif du programme, deux simulations ont étaient faites: une deterministe qui donne toujour le meme résultat et une aléatoire qui introduit plus de variabilité et donc est plus réaliste nous renseignant sur l'efficacité du programme. 

## États possibles pour une parcelle 
1) Vide
2) Herbe
3) Buisson 1
4) Nuisson 2

## Matrice de transition et stades de succession possible 

La matrice de transition contient les probabilités qui décrivent la chance de l'évolution d'un système d'un état à un autre.
La matrice de transition utilisé dans ce modèle possède les propriétés des chaînes de Markov. En effet, chaque changement ne depend que de l'état présent (processus sans mémoir).

### Succession :
- Vide --> Vide OU Herbe
- Herbe --> Vide OU Herbe OU Buisson 1 OU Buisson 2
- Buisson 1 ---> Vide OU Herbe OU Buisson 1 
- Buisson 2 --> Vide OU Herbe OU Buisson 2

## Règles de l'équilibre biodiversité / sécurité des infrastructures

1) Parcelles non vide représentent 20% du terrain.
2) Parcelles dans l'états Herbe représentent 30% de la végétation totale.
3) Parcelles avec la variété de buisson la moins présentes représentent au moins 30% des buissons totaux.















