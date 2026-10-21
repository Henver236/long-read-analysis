Bien sûr \! J'ai lu la section Project 2: Long-read genome sequencing de la page du cours, ainsi que les indications et les liens complémentaires.

Introduction to Sequencing Data Analysis

Je vais te l'expliquer comme si on préparait l'exercice ensemble, en distinguant ce qu'il faut faire concrètement, pourquoi on le fait et ce que tu dois être capable de présenter à la fin.

## 1. Quel est l'objectif de l'exercice ?

Le but est d'aligner des séquences d'ARN longues, obtenues avec la technologie Nanopore, sur un génome humain de référence, puis de comparer les résultats entre deux échantillons biologiques.

Introduction to Sequencing Data Analysis

Pour comprendre le projet, voici le principe :

1. Les lectures Nanopore (FASTQ)

Des séquences d'ARN converties en lectures de séquençage, avec un score de qualité pour chaque base.

2. Contrôle qualité

FastQC et NanoPlot : longueur, qualité et caractéristiques des lectures.

3. Alignement avec minimap2

Associer les lectures aux positions correspondantes sur le génome de référence.

4. Analyse des alignements

Comparer les deux échantillons et visualiser le gène ELOVL5 dans IGV pour examiner l'épissage.

Le cours utilise deux échantillons issus d'une étude publiée en 2023 :

- `EV_2` : des vésicules extracellulaires (petites structures libérées par les cellules et contenant notamment du matériel moléculaire).
- `Cell_2` : des cellules entières en culture.

Les données ont été réduites à un sous-ensemble du génome et des lectures afin de rendre les calculs plus accessibles pendant la formation. Tu n'as donc pas à télécharger toi-même toutes les données brutes de l'étude originale.

Introduction to Sequencing Data Analysis

## 2. Ce qu'on attend de toi, étape par étape

### Étape 1 — Télécharger et comprendre les données

Le cours fournit une archive contenant les lectures et le génome de référence.

Depuis le terminal, dans ton répertoire de travail :

bash
```
wget https://ngs-introduction-training.s3.eu-central-1.amazonaws.com/project2.tar.gz
tar -xvf project2.tar.gz
rm project2.tar.gz
```

Tu devrais obtenir une structure contenant notamment :

- `reads/` : les fichiers de lectures FASTQ ;
- `reference/` : le génome de référence et son annotation.

Avant de poursuivre, inspecte le contenu :

bash
```
find . -maxdepth 3 -type f
```

Ce qu'il faut comprendre : les FASTQ contiennent les séquences observées expérimentalement. Le génome de référence est le modèle auquel tu vas comparer ces séquences.

Attention, comme tu travailles sous WSL avec de gros fichiers, conserve ces données dans ton espace de travail local et évite de les versionner dans Git.

### Étape 2 — Examiner la qualité des lectures

Tu dois utiliser deux outils : FastQC et NanoPlot.

bash
```
mkdir -p results/fastqc results/nanoplot

fastqc reads/*.fastq.gz -o results/fastqc
```

Adapte le motif `reads/*.fastq.gz` aux noms et formats réels des fichiers présents dans ton dossier.

Pour NanoPlot, la commande générale est :

bash
```
NanoPlot --fastq reads/TON_FICHIER.fastq.gz \
  -o results/nanoplot
```

Répète l'analyse pour les deux échantillons si nécessaire.

L'objectif n'est pas seulement de générer des rapports, mais de les interpréter.

- Quelle est la longueur moyenne des lectures ?
- Quelle est leur qualité moyenne ?
- Les résultats de FastQC et NanoPlot concordent-ils ?
- Les résultats sont-ils cohérents avec ce que rapporte l'étude publiée ?

Nanopore produit généralement des lectures plus longues que le séquençage Illumina, mais la qualité varie selon la technologie et les conditions de séquençage. Tu dois regarder les valeurs obtenues dans tes propres rapports plutôt que supposer qu'elles seront bonnes ou mauvaises.

### Étape 3 — Aligner les lectures sur le génome humain

C'est le cœur de l'exercice.

L'outil demandé est `minimap2`. La difficulté pédagogique principale est de choisir le bon paramètre `-x`, qui indique à l'outil quel type de séquences il doit aligner.

Le cours propose notamment de comparer ces deux modes :

| Paramètre | À quoi il sert |
| --- | --- |
| `-x map-ont` | Alignement général de lectures longues Nanopore, sans modèle spécifique d'épissage. |
| `-x splice` | Alignement de lectures d'ARN sur un génome, en tenant compte des introns et des jonctions d'épissage. |

Comme tu travailles avec des lectures issues de RNA-seq, le mode `splice` est particulièrement pertinent. Mais l'exercice te demande justement de comparer les résultats, et pas simplement de choisir un mode au hasard.

Introduction to Sequencing Data Analysis

Voici le modèle de commande donné dans le cours :

bash
```
minimap2 \
  -a \
  -x splice \
  reference/genome.fa \
  reads/TON_FICHIER.fastq.gz \
  | samtools sort \
  -o results/sample.splice.bam
```

Il faudra adapter les noms des fichiers au contenu réel de ton archive.

Les options importantes :

- `-a` : produit des alignements au format SAM.
- `-x splice` : utilise le preset adapté à l'alignement de lectures d'ARN épissées sur un génome.
- `samtools sort` : trie les alignements et écrit un fichier BAM, plus compact que le SAM.

Pour comparer les deux modes, exécute aussi la commande avec `-x map-ont`, en donnant un nom de sortie différent.

Par exemple, pour un même échantillon, tu obtiendras deux fichiers :

text
```
sample.map-ont.bam
sample.splice.bam
```

Fais la même comparaison pour `EV_2` et `Cell_2`.

Pourquoi est-ce important ? Un ARN mature peut être constitué de plusieurs exons séparés par des introns dans le génome. Un outil adapté à l'épissage doit pouvoir représenter correctement ces alignements discontinus. Le mode choisi peut donc modifier les positions alignées, les jonctions détectées et la qualité apparente de certains alignements.

### Étape 4 — Évaluer la qualité des alignements

Il ne suffit pas d'obtenir un fichier BAM : il faut déterminer si l'alignement est satisfaisant.

Tu dois notamment comparer :

- Le taux d'alignement : quelle proportion des lectures a pu être alignée sur la référence ?
- La qualité de mapping : avec quel niveau de confiance une lecture a-t-elle été placée à une position donnée ?
- La profondeur de séquençage : combien de lectures couvrent une région ou un gène ?
- Les différences entre `EV_2` et `Cell_2` : observe-t-on des variations dans les longueurs, la qualité des lectures, les taux d'alignement ou la couverture ?

Pour obtenir des statistiques générales sur un fichier BAM :

bash
```
samtools flagstat results/sample.splice.bam
```

Et pour compter les lectures alignées et obtenir des statistiques plus détaillées :

bash
```
samtools stats results/sample.splice.bam \
  > results/sample.splice.stats.txt
```

Tu peux aussi indexer les BAM triés pour faciliter leur consultation dans IGV :

bash
```
samtools index results/sample.splice.bam
```

Il faudra répéter les commandes pour chaque échantillon et chaque mode que tu veux comparer.

Attention : un taux d'alignement élevé ne garantit pas à lui seul un alignement biologiquement correct. C'est pour cela que le cours demande aussi d'examiner les alignements visuellement.

### Étape 5 — Visualiser le gène `ELOVL5` dans IGV

Le cours te demande explicitement d'examiner le gène `ELOVL5` dans IGV, un logiciel de visualisation des alignements génomiques.

Introduction to Sequencing Data Analysis

IGV 可视化工具官方--04 - IGV | RNA-Seq Data Basics | Splice Junction Track, Downsampl\_哔哩哔哩\_bilibili

Alignment Visualization - IGV | Griffith Lab

Read alignment | \[“Introduction to RNA Sequencing Bioinformatics”\]

Dans IGV, tu devras charger :

- le génome de référence approprié ;
- le BAM de `EV_2` et son index ;
- le BAM de `Cell_2` et son index.

Puis rechercher `ELOVL5`.

Voici ce que tu dois observer :

- Les lectures couvrent-elles les mêmes exons dans les deux échantillons ?
- Vois-tu des lectures qui relient des exons séparés par un intron ?
- Certaines jonctions d'épissage semblent-elles plus fréquentes dans un échantillon ?
- Les modes `map-ont` et `splice` donnent-ils des représentations différentes ?

Une variante d'épissage correspond à une différence dans la façon dont les exons sont assemblés dans les transcrits. Par exemple, un transcrit peut inclure un exon qu'un autre transcrit omet.

Tu dois chercher des indices dans les alignements, pas nécessairement prouver définitivement l'existence d'une nouvelle isoforme. Une couverture insuffisante ou des erreurs d'alignement peuvent aussi expliquer certaines observations.

### Étape 6 — Comprendre les jonctions d'épissage dans les fichiers SAM

C'est une question plus technique du projet, mais elle est importante pour interpréter IGV.

Dans un fichier SAM, la colonne `CIGAR` décrit comment une lecture s'aligne sur la référence.

Par exemple :

text
```
75M1200N90M
```

Cela signifie, schématiquement :

- `75M` : 75 bases alignées ;
- `1200N` : une région de 1 200 bases sautée sur la référence, correspondant généralement à un intron dans un alignement d'ARN épissé ;
- `90M` : 90 bases alignées après cette région.

Le symbole `N` est donc particulièrement important ici. Le preset `splice` de minimap2 permet de représenter les introns de cette manière.

GitHub

+1

Tu dois comparer les fichiers produits par `map-ont` et `splice` pour déterminer si les jonctions sont représentées différemment.

## 3\. Les questions auxquelles tu dois pouvoir répondre

La page du cours propose plusieurs questions. Voici comment les aborder.

| Question du cours | Ce que tu dois faire pour y répondre |
| --- | --- |
| Quelle est la longueur moyenne des lectures ? | Lire les rapports FastQC et NanoPlot et comparer les deux échantillons. |
| Quelle est leur qualité moyenne ? | Examiner les scores de qualité et comprendre leur relation avec la probabilité d'erreur. |
| Pourquoi FastQC et NanoPlot donnent-ils des résultats différents ? | Étudier ce que chaque outil mesure et comment il calcule ou présente les statistiques. |
| Les paramètres de minimap2 par défaut sont-ils appropriés ? | Comparer `map-ont` et `splice`, puis examiner les taux et les caractéristiques des alignements. |
| Comment les alignements épissés sont-ils représentés dans SAM ? | Examiner la colonne CIGAR et notamment l'opérateur `N`. |
| Quelle est la profondeur du gène `ELOVL5` dans les deux échantillons ? | Examiner les couvertures dans IGV et comparer les lectures qui couvrent ce gène. |
| Voit-on des indices de variantes d'épissage ? | Examiner les exons et les jonctions soutenus par les lectures, en tenant compte de la couverture. |

Ces questions et les liens d'aide associés sont ceux du projet 2.

Introduction to Sequencing Data Analysis

Pour comprendre la qualité, le score Phred suit la relation :

$$
Q=-10\log_{10}(P_{\mathrm{erreur}})
$$

Par exemple, un score $Q=20$ correspond à une probabilité d'erreur de 1 % pour une base, et $Q=30$ à 0,1 %. Attention, la qualité moyenne d'une lecture ne se traduit pas directement en une moyenne arithmétique des probabilités d'erreur : c'est justement l'une des subtilités discutées dans le [billet du développeur de NanoPlot](<https://gigabaseorgigabyte.wordpress.com/2017/06/26/averaging-basecall-quality-scores-the-right-way/?utm_source=chatgpt.com>).

Wikipedia

+1

## 4\. Qu'est-ce que tu dois rendre à la fin ?

La page présente cet exercice comme un projet d'apprentissage par la pratique. Les groupes doivent conclure leur travail par une présentation de dix minutes ; les tâches et questions servent de guide, sans qu'il soit obligatoire de toutes les réaliser.

Introduction to Sequencing Data Analysis

Je te conseille de préparer les éléments suivants :

- Les scripts qui permettent de reproduire les étapes de l'analyse.
- Les rapports FastQC et NanoPlot des deux échantillons.
- Les fichiers BAM triés et indexés pour les alignements comparés.
- Un petit tableau récapitulatif des statistiques d'alignement.
- Des captures d'écran d'IGV montrant `ELOVL5` et les jonctions intéressantes.
- Une conclusion expliquant les différences observées entre les deux échantillons et entre les paramètres d'alignement.

Le cours insiste également sur la reproductibilité : utilise des scripts numérotés, des noms explicites et des variables définies au début des scripts. Tu peux consulter le chapitre [Reproducibility](<https://sib-swiss.github.io/sequencing-data-analysis-training/latest/day1/reproducibility/?utm_source=chatgpt.com>) pour ces bonnes pratiques.

Introduction to Sequencing Data Analysis

## 5\. Mon conseil pour ne pas te disperser

N'essaie pas de tout comprendre et de tout lancer en même temps. Procède dans cet ordre :

## Ta feuille de route

0/6

[ ]Télécharger les données et repérer les fichiers FASTQ et la référenceVérifier l'arborescence et les noms des fichiers.

[ ]Exécuter FastQC et NanoPlotLire les rapports avant de passer à l'alignement.

[ ]Aligner EV\_2 et Cell\_2 avec les deux presetsProduire des BAM distincts pour map-ont et splice.

[ ]Comparer les statistiquesTaux d'alignement, qualité de mapping et profondeur.

[ ]Examiner ELOVL5 dans IGVComparer les couvertures et les jonctions d'épissage.

[ ]Préparer les conclusionsRépondre aux questions avec des chiffres et des captures d'écran.

## Pour qu'on puisse avancer concrètement

Comme tu travailles déjà sur un pipeline sous WSL, je te propose de construire celui-ci progressivement plutôt que de te donner un long script que tu ne comprendrais pas encore.

Est-ce que tu as déjà téléchargé et décompressé `project2.tar.gz`, ou est-ce que tu pars complètement de zéro pour cet exercice ?

Selon ta réponse, je pourrai t'accompagner à partir de ton arborescence réelle, avec les commandes adaptées à tes fichiers.