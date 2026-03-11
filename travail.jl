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

Cette fonction vérifie que la somme de chaque ligne de 'T' est égale à 1, et si ce n'est pas le cas elle renvoi un warning pour signaler qu'elle fera des modifications sur l'objet 'T' pour faire en sorte que la somme de chache ligne soit égale à 1

'T' doit être une matrice 
"""
function check_transition_matrix!(T)
    # axes(T,1) retourne les indices de la premiere dimention de T donc les lignes
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

Cette fonction vérifie que la matrice de transition 'transition' est carrée donc que le nombre de ses lignes est égale au nombre de ses colonne et si ce n'est pas le cas elle arrête le programme et affiche un message d'erreur 
elle vérifie aussi que le nombre de ligne de la matrice de transition est égale au nombre d'états possible et si ce n'est pas le cas elle arrête le programme et affiche un message d'erreur 

'transitions' doit être une matrice de transition et 'states' doit être un vecteur avec les états possibles de la matrice de transition
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

Cette fonction

'timeseries' doit être une matrice
'transitions' doit être 
'generation' doit être le nombre de la génération dans laquelle on se trouve
"""
function _sim_stochastic!(timeseries, transitions, generation)
    for state in axes(timeseries, 1)
        #Multinomial() cree échantillon aléa suivant une loi multinomiale (généralisation de la loi binomiale)
        pop_change = rand(Multinomial(timeseries[state, generation], transitions[state, :]))
        timeseries[:, generation+1] .+= pop_change
    end
end

"""
_sim_determ!(timeseries, transitions, generation)

Cette fonction

'timeseries' doit être une matrice
'transitions' doit être 
'generation' doit être le nombre de la génération dans laquelle on se trouve
"""
function _sim_determ!(timeseries, transitions, generation)
    pop_change = (timeseries[:, generation]' * transitions)'
    timeseries[:, generation+1] .= pop_change
end

function simulation(transitions, states; generations=500, stochastic=false)

    check_transition_matrix!(transitions)
    check_function_arguments(transitions, states)
    
    #si determinist pop continue (car on calcule des proba) sinon pop entiere (car le vrai truc qui arrive)
    _data_type = stochastic ? Int64 : Float32
    timeseries = zeros(_data_type, length(states), generations + 1)
    timeseries[:, 1] = states

    _sim_function! = stochastic ? _sim_stochastic! : _sim_determ!

    for generation in Base.OneTo(generations)
        _sim_function!(timeseries, transitions, generation)
    end

    return timeseries
end

# States
# Barren, Grass, Shrubs
s = [100, 0, 0]
states = length(s)
patches = sum(s)

# Transitions
T = zeros(Float64, states, states)
T[1, :] = [110, 8, 0]
T[2, :] = [2, 120, 3]
T[3, :] = [1, 0, 94]
T

states_names = ["Barren", "Grasses", "Shrubs"]
states_colors = [:grey40, :orange, :teal]

# Simulations

f = Figure()
ax = Axis(f[1, 1], xlabel="Nb. générations", ylabel="Nb. parcelles")

# Stochastic simulation
for _ in 1:100
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