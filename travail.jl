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
# Ensuite, les parcelles seront laissés sans intervention pour permettre le développement naturel de la biodivéersité.

# Sachant que l'état de chaque parcelle change d'une génération à l'autre, les questions posées sont : 
# combien de buissons faut-il planter pour obtenir un equilibre où 20% du terrain est végétalisé (dont 70% des buissons) après plusieurs générations ?
# Et combien de buissons faut-il choisir de chaque variétés pour que la variété la moins commune représente au moins 30% des buissons ?

# L'hypothèse est que le modèle proposé permet de simuler l'évolution de l'état des parcelles au fil des générations et ainsi d'estimer combien de 
# buissons, au total et de chauque variété, il faudrait planter au début pour abboutir à l'équilibre souhaité dans 80% des simulations.

# Résultat attendus : une certaines proportion des parcelles vides deviendront des parcelles couvertes herbes, avec ensuite une probabilité 
# plus grande qu'elles évoluent vers des buissons d'une des deuc variétés. Une proportion des parcelles végétalisées redeviendra vide.
# L'objectif est d'obtenir une bonne estimation du nombre de buissons à planter pour aménager efficacement le terrain.

# # Présentation du modèle

# # Implémentation

# ## Packages nécessaires

import Random
Random.seed!(123456)
using CairoMakie

# ## Une autre section

"""
    foo(x, y)

Cette fonction ne fait rien.
"""
function foo(x, y)
    ## Cette ligne est un commentaire
    return nothing
end

# # Présentation des résultats

# La figure suivante représente des valeurs aléatoires:

hist(randn(100))

# # Discussion

# On peut aussi citer des références dans le document `references.bib`,
# @ermentrout1993cellular -- la bibliographie sera ajoutée automatiquement à la
# fin du document.

using CairoMakie
using Distributions

import Random
Random.seed!(2045)

"""
    check_transition_matrix!(T)

Cette fonction vérifie que la somme de chaque ligne de 'T' est égale à 1. Si ce n'est pas le cas, elle renvoie un warning pour signaler qu'elle va modifier l'objet 'T' afin que la somme de chache ligne soit égale à 1

'T' doit être une matrice de probabilités.
"""
function check_transition_matrix!(T)
    # axes(T,1) retourne les indices de la premiere dimension de T donc les lignes
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

Cette fonction vérifie que la matrice de transition 'transitions' est carrée donc que le nombre de ses lignes est égal au nombre de ses colonnes. Si ce n'est pas le cas, elle arrête le programme et affiche un message d'erreur.
Elle vérifie aussi que le nombre de ligne de la matrice de transition est égal au nombre d'états possible. Si ce n'est pas le cas, elle arrête le programme et affiche un message d'erreur.

'transitions' doit être une matrice de probabilités.
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
'generation' doit être un nombre.
"""
function _sim_stochastic!(timeseries, transitions, generation)
    for state in axes(timeseries, 1) # state = indices des lignes (états)
        #Multinomial() cree échantillon aléatoire suivant une loi multinomiale
        #Multinomial(n, p) = génère un tirage aléatoire de n objets répartis selon les probabilités p
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
'generations' est par défaut égal à 500 et 'stochastic' est par défaut false
"""
function simulation(transitions, states; generations=500, stochastic=false)

    check_transition_matrix!(transitions)
    check_function_arguments(transitions, states)
    
    #Si déterministe : poppulation continue (calcul de probabilités) 
    #Sinon : populaiton entière (simulation stochastique)
    _data_type = stochastic ? Int64 : Float32
    timeseries = zeros(_data_type, length(states), generations + 1) #état initial
    timeseries[:, 1] = states 
    
    # Choix de la fonction selon le type de simulation
    _sim_function! = stochastic ? _sim_stochastic! : _sim_determ!
    
    # Base.OneTo(X) crée une boucle qui va de 1 à X
    # boucle qui remplit la matrice avec les nouveaux changements
    for generation in Base.OneTo(generations)
        _sim_function!(timeseries, transitions, generation)
    end

    return timeseries
end

# States
# Barren, Grass, Shrubs1, Shrubs2
s = [200, 0, 0, 0]
states = length(s)
patches = sum(s)

# Transitions
T = zeros(Float64, states, states)
T[1, :] = [110, 8, 0, 0]
T[2, :] = [2, 120, 4, 3] # faut changer ici pour les proba des buisson
T[3, :] = [1, 0, 94, 0]
T[4, :] = [1, 0, 0, 94]
T

states_names = ["Barren", "Grasses", "Shrubs1", "Shrubs2"]
states_colors = [:grey40, :orange, :teal, :green] # on peut peut etre trouver d'autre couleur si tu veux

# Simulations

f = Figure()
ax = Axis(f[1, 1], xlabel="Nb. générations", ylabel="Nb. parcelles")

# Stochastic simulation
for _ in 1:200
    sto_sim = simulation(T, s; stochastic=true, generations=200)
    for i in eachindex(s)
        lines!(ax, sto_sim[i, :], color=states_colors[i], alpha=0.1)
    end
end

# Deterministic simulation
det_sim = simulation(T, s; stochastic=false, generations=200)
for i in eachindex(s)
    lines!(ax, det_sim[i, :], color=states_colors[i], alpha=1, label=states_names[i], linewidth=4)
end

axislegend(ax)
tightlimits!(ax)
current_figure()
