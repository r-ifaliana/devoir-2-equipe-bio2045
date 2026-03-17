# ---
# title: Devoir 2 - Succession végétale
# repository: tpoisot/BIO245-modele
# auteurs:
#    - nom: Ranaivo Rajaonarisoa
#      prenom: Ifaliana
#      matricule: 20325981
#      github: premierAuteur
#    - nom: Ben Brahim
#      prenom: Dorra
#      matricule: 20302117
#      github: DeuxiAut
# ---

# # Introduction

# Pour rendre la ville plus verte tout en assurant la sécurité des infrastructures,
# il est important de savoir comment bien aménager les espaces publics.
# La construction d'une ligne haute tension a permis le dégagement d'un terrain de 200 parcelles.
# Un corridor conciliant biodiversité et sécurité sera aménagé, afin d'optimiser l'utilisation de cet espace libre.
# Pour cela, un maximum de 50 buissons de deux variétés différentes pourront être plantés sur ce terrain.
# Ensuite, les parcelles seront laissées sans intervention pour permettre le développement naturel de la biodiversité.

# Sachant que l'état de chaque parcelle change d'une génération à l'autre, les questions posées sont : 
# combien de buissons faut-il planter pour obtenir un equilibre où 20% du terrain est végétalisé (dont 70% des buissons) après plusieurs générations ?
# Et combien de buissons faut-il choisir de chaque variétés pour que la variété la moins commune représente au moins 30% des buissons ?

# L'hypothèse est que le modèle proposé permet de simuler l'évolution de l'état des parcelles au fil des générations et ainsi d'estimer combien de 
# buissons, au total et de chaque variété, il faudrait planter au début pour abboutir à l'équilibre souhaité dans 80% des simulations.

# Résultat attendu : une certaine proportion des parcelles vides deviendront des parcelles couvertes herbes, avec ensuite une probabilité 
# plus grande qu'elles évoluent vers des buissons d'une des deux variétés. Une proportion des parcelles végétalisées redeviendra vide.
# L'objectif est d'obtenir une bonne estimation du nombre de buissons à planter ainsi que des probabilités de transition pour aménager efficacement le terrain.

# # Présentation du modèle

# Le modèle utilisé est un modèle de transition entre états, dans lequel chaque parcelle du terrain peut se trouver dans un état écologique précis.
# À chaque génération, l'état d'une parcelle peut changer selon les probabilités définies dans une matrice de transition.

# Dans notre cas, quatre états sont considérés : sol nu (Barren), herbes (Grass), buissons de variété 1 (Shrubs1), buissons de variété 2 (Shrubs2).
# L'évolution des parcelles est décrite par une matrice de transition où chaque ligne représente l'état d'une parcelle au temps t et chaque colonne
# la probabilité de transition vers un nouvel état à la génération suivante. La somme des probabilités de chaque ligne doit être égale à 1.

# Ce modèle correspond à une chaîne de Markov où l'état au temps t+1 dépend uniquement de l'état actuel et de la probabilité de transition qui va avec.
# Il permet de simuler l'évolution des parcelles dans chaque état au cours des générations afin d'avoir une bonne estimation du nombre de buissons à planter
# tout en respectant les contraintes imposées (50 buissons à planter sur 200 parcelles) afin d'optimiser l'aménagement du terrain.

# # Implémentation

# Le modèle est implémenté dans Julia à partir du code fourni pour simuler les transitions végétales.
# Il utilise une matrice qui correspond à l'évolution de chaque état au cours du temps. 
# Une simulation déterministe est utilisée, qui calcule l'évolution attendue des parcelles, la simulation stochastique quant à elle,
# introduit des aléas dans les transitions de chaque état. 
# Des fonctions de vérification permettent également de s'assurer que la matrice de transition et les arguments fournis sont cohérents 
# avant de faire marcher la simulation.

# ## Packages nécessaires

import Random
using CairoMakie
using Distributions

# ## Point de départ standard

Random.seed!(2045)

# ## Fonctions utilisées

"""
    check_transition_matrix!(T)

Cette fonction vérifie que la somme de chaque ligne de 'T' est égale à 1. 
Si ce n'est pas le cas, elle renvoie un warning pour signaler qu'elle va modifier l'objet 'T' afin que la somme de chache ligne devienne égale à 1

'T' doit être une matrice de probabilités.
"""
function check_transition_matrix!(T)

    ## axes(T,1) retourne les indices de la premiere dimension de T (donc les lignes)

    for ligne in axes(T, 1) 
        if sum(T[ligne, :]) != 1
            @warn "La somme de la ligne $(ligne) n'est pas égale à 1 et a été modifiée"
            T[ligne, :] ./= sum(T[ligne, :])
        end
    end
    return T
end


"""
    check_function_arguments(transitions, states)

Cette fonction vérifie que la matrice de transition est carrée donc que le nombre de ses lignes est égal au nombre de ses colonnes. Si ce n'est pas le cas, elle arrête le programme et affiche un message d'erreur.
Elle vérifie aussi que le nombre de ligne de la matrice de transition est égal au nombre d'états possible. Si ce n'est pas le cas, elle arrête le programme et affiche un message d'erreur.

'transitions' est la matrice de transision, elle doit être une matrice de probabilités.
'states' doit être un vecteur de nombres.
"""
function check_function_arguments(transitions, states)
    if size(transitions, 1) != size(transitions, 2)
        throw("La matrice de transition n'est pas carrée")
    end

    if size(transitions, 1) != length(states)
        throw("Le nombre d'états ne correspond pas à la matrice de transition")
    end
    
    return nothing
end


"""
    _sim_stochastic!(timeseries, transitions, generation)

Cette fonction génère aléatoirement la population au temps t+1 à partir de la population présente au temps t.

'timeseries' doit être une matrice d'états.
'transitions' doit être une matrice de probabilités.
'generation' doit être un nombre entier.
"""
function _sim_stochastic!(timeseries, transitions, generation)
    for state in axes(timeseries, 1) # state = indices des lignes (états)

        ## Multinomial() cree échantillon aléatoire suivant une loi multinomiale
        ## Multinomial(n, p) = génère un tirage aléatoire de n objets répartis selon les probabilités p

        pop_change = rand(Multinomial(timeseries[state, generation], transitions[state, :]))
        timeseries[:, generation+1] .+= pop_change
    end
end


"""
    _sim_determ!(timeseries, transitions, generation)

Cette fonction génère de façon déterministe la nouvelle génération au temps t+1 à partir de la population existante au temps t.

'timeseries' doit être une matrice d'états.
'transitions' doit être une matrice de probabilités.
'generation' doit être un nombre.
"""
function _sim_determ!(timeseries, transitions, generation)
    pop_change = (timeseries[:, generation]' * transitions)'
    timeseries[:, generation+1] .= pop_change
end


"""
    simulation(transitions, states; generations=500, stochastic=false)

Cette fonction effectue la simulation.
Elle vérifie que les arguments sont corrects
et adapte les estimations de l'evolution de la population selon le modèle choisi (stochastique ou déterministe)

'transitions' doit être une matrice de probabilités.
'states'doit être un vecteur de nombres.
'generations' est par défaut égal à 500 et 'stochastic' est par défaut false, pour les modifier il faut leurs attribuer la valeur souhaité comme suit : argument = nouvelle_valeur.
exemple : stochastic = true ou generation = 400.
"""
function simulation(transitions, states; generations=500, stochastic=false)

    check_transition_matrix!(transitions)
    check_function_arguments(transitions, states)
    
    ## Si déterministe : poppulation continue (calcul de probabilités) 
    ## Sinon : populaiton entière (simulation stochastique)

    _data_type = stochastic ? Int64 : Float32
    timeseries = zeros(_data_type, length(states), generations + 1) #état initial
    timeseries[:, 1] = states 
    
    ## Choix de la fonction selon le type de simulation

    _sim_function! = stochastic ? _sim_stochastic! : _sim_determ!
    
    ## Base.OneTo(X) crée une boucle qui va de 1 à X
    ## boucle qui remplit la matrice avec les nouveaux changements

    for generation in Base.OneTo(generations)
        _sim_function!(timeseries, transitions, generation)
    end

    return timeseries
end


"""
    check_conditions(timeseries; tolerance=0.05)

Vérifie 3 conditions à la dernière génération : 
1) >= 20% des parcelles sont végétalisées.
2) 30% des parcelles végétalisées sont des herbes.
3) La variété de buisson la moins abondante représente >= 30% des buissons.
Retourne "true" selon si la condition respectée.
Donc renvoie 3 valeurs booléennes.

'timeseries' doit être une matrice d'états.
'tolerance' est fixé à 0.05 par défaut.
"""
function check_conditions(timeseries; tolerance=0.05)
    
    ## On récupère la dernière colonne (état final)
    
    etat_final = timeseries[:, end]

    Barren = etat_final[1]
    Grass = etat_final[2]
    Shrubs1 = etat_final[3]
    Shrubs2 = etat_final[4]

    total_parcelles = sum(etat_final)
    Vegetation = Grass + Shrubs1 + Shrubs2
    shrubs_total = Shrubs1 + Shrubs2

    ## Condition 1 = au moins 20% de parcelles végétalisées

    cond1 = (0.2-tolerance)<=(Vegetation / total_parcelles)<= (0.2+tolerance)

    ## Condition 2 = 30% des parcelles végétalisées doivent être des herbes

    if Vegetation > 0
        cond2 = (0.30-tolerance)<=(Grass/Vegetation)<=(0.30+tolerance)
    else
       cond2 = false
    end   

    ## Condition 3 = la variété de buisson la moins abondante doit faire au moins 30% du total des buissons

    if shrubs_total > 0
        cond3 = (min(Shrubs1, Shrubs2)/shrubs_total) >= 0.30
    else
        cond3 = false
    end
        
    ## Code pour l'affichage des pourcentages pour chaque condition pour l'ajustement de la matrice de transision.
    ## Affichage non exécuté pour alléger l'exécution, symbole '#' à enlever pour afficher les données. 

    ## println("% de végétation =", (Vegetation/total_parcelles)*100, "%")
    ## println("% de herbes =", (Grass/Vegetation)*100, "%")
    ## println("% de buisson minimum =", (min(Shrubs1, Shrubs2)/shrubs_total)*100, "%")
    
    return cond1, cond2, cond3
end


"""
    check_80(condition_respecté, repet_simulation)

cette fonction vérifie qu'au moins 80% des simulations vérifient les conditions d'équilibre du modèle.

'condition_respecté' doit être un nombre entier (représentant le nombre de fois où toutes les conditions sont respectées)
'repet_simulation' doit être un nombre entier (représentant combien de fois la simulation sera répétée )
"""
function check_80(condition_respecté, repet_simulation)

    ## Pourcentage de simulation respectant les 3 conditions 
    
    condition_respecté = (condition_respecté/repet_simulation)*100
    
    if condition_respecté >= 80
        return true, println("Conditions d'équilibre respécté dans", condition_respecté ,"% des simulations")
    else
        return false, println("Simulation non concluante! conditions respectées uniquement dans ", condition_respecté, "% des cas")
    end
end

# ## Définitions des variables

# État initial des parcelles
# Barren, Grass, Shrubs1, Shrubs2

s = [150, 0, 25, 25]
states = length(s)
patches = sum(s)

# Matrice de transitions

T = zeros(Float64, states, states)
T[1, :] = [0.98, 0.02, 0.0, 0.0]
T[2, :] = [0.2, 0.66, 0.065, 0.075]
T[3, :] = [0.02, 0.035, 0.9, 0.0]
T[4, :] = [0.02, 0.035, 0.0, 0.9]
T

# Noms et couleurs attribué aux différents états

states_names = ["Barren", "Grasses", "Shrubs1", "Shrubs2"]
states_colors = [:grey40, :orange, :teal, :green] 

# ## Simulations

f = Figure()
ax = Axis(f[1, 1], xlabel="Nb. générations", ylabel="Nb. parcelles")


# Deterministic simulation

det_sim = simulation(T, s; stochastic=false, generations=200)
for i in eachindex(s)
    lines!(ax, det_sim[i, :], color=states_colors[i], alpha=1, label=states_names[i], linewidth=4)
end

# Stochastic simulation

nb_condition_respecté = 0
repet_simulation = 200
for _ in 1:repet_simulation
    sto_sim = simulation(T, s; stochastic=true, generations=200)
    cond1, cond2, cond3 = check_conditions(sto_sim)
    if cond1 & cond2 & cond3
        global nb_condition_respecté = nb_condition_respecté +1
    end
    for i in eachindex(s)
        lines!(ax, sto_sim[i, :], color=states_colors[i], alpha=0.1)
    end
end
println(check_80(nb_condition_respecté, repet_simulation))

# Graphique des résulats de simulations 

axislegend(ax)
tightlimits!(ax)
current_figure()


# # Présentation des résultats

# Deux simulations ont été réalisées, une première déterministe et une seconde stochastique.

# La simulation déterministe a permis de trouver les valeurs de la matrice de transition,
# qui ont permis l'obtention d'une distribution finale respectant les trois conditions suivantes :
# 1) La végétation (herbes + buisson1 + buisson2) représente 20% du terrain, avec une intervalel de tolérance de 10%.
# 2) L'herbe représente 30% de la végétation, avec une intervalle de tolérance de 10%.
# 3) La variété de buisson la moins commune sur le terrain représente au moins 30% des buissons.
# À la fin de cette simulation le terrain obtenu se compose de 21.48% de végétation dont 29.15% sont de l'herbe. Et la variété de buisson la moins présente représente 46.43% des buissons.
# La simulation stochastique est réalisé par création aléatoire de la population de la génération suivante.
# La répétition (200 fois) de la simulation stochastique a permis l'obtention du pourcentage de bon fonctionnement qui est de 47.5%.
# Ce pourcentage mesure combien de fois la simulation a respecté les 3 conditions.

# Figure : Camembert des valeurs obtenu à la fin de la simulation deterministe 
# pie(valeurs= vecteur, color=vecteur)

etat_F= det_sim[:,end]
pie(etat_F, color= states_colors)

# # Discussion

# Les simulations réalisées permettent de simuler comment un corridor végétalisé peut évoluer à partir d'un nombre limité de buissons plantés.
# Le modèle utilisé reprend le principe d'une succession végétale où les parcelles de sol nu peuvent être colonisés par des herbes, qui peuvent ensuite évoluer vers des états dominés par des buissons.
# Cette succession écologique est retrouvée dans de nombreux écosystèmes où les espèces pionnières colonisent d'abord les milieux perturbés avant d'être progressivement remplacés par des espèces plus compétitives @connell1977succession.

# La simulation déterministe montre que la matrice de transition choisie permet d'atteindre un état d'équilibre respectant les conditions imposées. Cependant, lorsque le modèle stochastique est pris en compte, ce caractère aléatoire malgré la répétition de 200fois 
# ne permet d'atteindre une réussite dans 47.5% des simulations. Ce résultat est nettement inférieur à l'objectif initial, qui était d'obtenir au moins 80% de réussite. 
# Cet écart prouve que la simulation proposée permet théoriquement d'atteindre l'état final souhaité, mais que la variabilité aléatoire du système réduit fortement la probabilité 
# que cet équilibre soit atteint dans la pratique.

# Plusieurs éléments du modèle peuvent expliquer cette différence. Par exemple, les probabilités de transition favorisent fortement la persistance des buissons,
# avec une probabilité de 0.9 de rester dans le même état. Une fois établis, les buissons on tendance à rester dans le système. 
# Dans le modèle stochastique, les petits variations montrent un gros impact quant à la composition finale de la végétation. 

# Le fait de ne pa atteindre les 80% de réussite suggère que la situation initiale et/ou les probabilités de transition pourraient encore être ajsutées pour augmenter la stabilité du système. 
# Par exemple, augmenter légèrement la probabilité de transition des herbes vers les buissons ou modifier la proportion initiale des deux espèces de buissons pourraient améliorer la probabilité d'obtenir l'équilibre souhaité.
# Le modèle repose sur une chaîne de Markov simple dans laquelle l'état futur d'une parcelle dépend uniquement de son état actuel et non de l'état des parcelles voisines.
# Ce qui crée une limite car dans des écosystème réels, la succession végétale est fortement influencée par des facteurs en plus, tels que les interactions spatiales, la dispersion des graines
# ou la dispersion des graines ou les conditions environnementales locales @wetherington2022succession, @taylor2009forestsuccession. Ces processus peuvent modifier la dynamique de colonisation et de remplacement des espèces et ne sont pas pris en compte dans ce modèle simplifié.

# # Conclusion 

# Pour conclure, malgré les simplications, la simulation permet d'explorer différent scénarios d'aménagement et d'illustrer comment les probabilités de transition et les conditions initiales
# ont un effet sur l'évolution d'un système écologique. 
# Les résultats montrent que le modèle proposé peut atteindre l'équilirbe souhaité dans certaines situations, mais que la variabilité 
# naturelle du système rend cet équilibre incertain lorsque l'on tient compte du caractère stochastique des dynamiques écologiques. 
# Cela illustre l'importance de considérer la variabilité aléatoire dans les dynamiques écologiques lors de la planification d'aménagements. 
