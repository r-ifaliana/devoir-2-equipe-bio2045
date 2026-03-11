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
# il est important de savoir comment bien aménager les espaces publiques.
# La construction d'une ligne haute tension a permis le dégagement d'un terrain de 200 parcelles.
# Un corridor consiliant biodiversité et sécurité sera aménagé, afin d'optimiser l'utilisation de cet espace libre.
# Pour cela, un maximum de 50 buissons de deux variétés différentes seront plantés dans ce terrain, 
# Ensuite, les parcelles seront laissés sans intervention pour permettre le développement naturel de la biodivéersité.

# Sachant que l'état de chaque parcelle change d'une génération à l'autre, les questions posés seraient de savoir 
# combien de buissons faut-il planter pour avoir un equilibre de 20% du terrain végétalisé (dont 70% sont des buissons) après plusieurs générations ?
# Et combien de buissons faut-il choisir de chaque variétés pour avoir à la fin un pourcentage supérieur à 30 % pour la varité la moins commune ?

# L'hypothèse serait que le modèle proposé permettrait de simuler l'évolution des états des parcelles du terrain au fils des générations permettant d'avoir des valeurs exactes de combien de buissons,
# au total et de de chauqe variétés, il faudrait planter au début pour abboutir à l'équilibre souhaité dans 80% des simulations.

# Résultat attendus : une certaines proportion des parcelles vides croitront en herbes, avec une probabilité plus grande ensuite qu'ils continue de croitre en buisson d'une des deux variétés.
# Une proportion des parcelles végétalisé mourront et redeviendront vide.
# Obtenir une bonne estimation du nombre de buissons à planter pour bien aménager le terrain.

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

function check_transition_matrix!(T)
    for ligne in axes(T, 1)
        if sum(T[ligne, :]) != 1
            @warn "La somme de la ligne $(ligne) n'est pas égale à 1 et a été modifiée"
            T[ligne, :] ./= sum(T[ligne, :])
        end
    end
    return T
end

function check_function_arguments(transitions, states)
    if size(transitions, 1) != size(transitions, 2)
        throw("La matrice de transition n'est pas carrée")
    end

    if size(transitions, 1) != length(states)
        throw("Le nombre d'états ne correspond psa à la matrice de transition")
    end
    return nothing
end

function _sim_stochastic!(timeseries, transitions, generation)
    for state in axes(timeseries, 1)
        pop_change = rand(Multinomial(timeseries[state, generation], transitions[state, :]))
        timeseries[:, generation+1] .+= pop_change
    end
end

function _sim_determ!(timeseries, transitions, generation)
    pop_change = (timeseries[:, generation]' * transitions)'
    timeseries[:, generation+1] .= pop_change
end

function simulation(transitions, states; generations=500, stochastic=false)

    check_transition_matrix!(transitions)
    check_function_arguments(transitions, states)

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
