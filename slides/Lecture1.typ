// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)
#set page(background: align(left+top, box(inset: 0.75in, image("logo.jpg", width: 1.5in))))

#show: doc => article(
  title: [Introduction to clinical research designs],
  subtitle: [DClin Research Methods 1],
  authors: (
    ( name: [Dr Christopher Wilson],
      affiliation: [Teesside University],
      email: [] ),
    ),
  toc: true,
  toc_title: [Contents],
  toc_depth: 2,
  cols: 1,
  doc,
)

== Overview
<overview>
There are many ongoing discussions in clinical psychology research. They will be picked up in other sessions this year. Today we will discuss:

- The link between research and effective treatment

- Clinical analogue studies

- Open and reproducible research

== Linking this to the development of your own thesis project…
<linking-this-to-the-development-of-your-own-thesis-project>
- Twp of the most important (but sometimes neglected) aspects of the thesis project are the #strong[rationale and the research question];.

- A project with a clear research question and strong rationale, is one that has deep connections to the existing theoretical models and prior findings on a topic.

- This helps make the case for why the research is needed. While the contribution it makes to knowledge and practice, and the clinical relevance of the work are clear to the reader.

== When designing a research project, consider the following:
<when-designing-a-research-project-consider-the-following>
- If you know of an existing relationship between variables in the literature, what is the rationale for your project?

- Stating that something "has not been done before" is not the same as explaining why it should be done.

- If your rationale/question implies that you want to understand the "why" of a particular topic, does your research design allow you to do this?

== Research designs in clinical psychology
<research-designs-in-clinical-psychology>
- A wide range of approaches are commonly used: Experimental and quasi-experimental, correlational, case study, and qualitative designs.

- To investigate psychological disorders, assessment, treatment, prevention, professional training, ethics, and cultural diversity.

#block[
@Blampied1998Research@ComerKendall2013@Kazdin2021Research@2005Handbook@Sanderson1991Research

]
== Types of psychopathology research
<types-of-psychopathology-research>
#box(image("images/psychopathologyResearch.png"))

@ComerKendall2013

== Experimental psychopathology research
<experimental-psychopathology-research>
Sometimes referred to as "Type 1" clinical research @ComerKendall2013

- Able to identify putative causal variables that are directly manipulable (i.e., How or why might psychopathology develop?).

- May serve as the "building blocks" of future intervention eﬀorts.

- Rarely (unfortunately) followed through to the point of application.

#block[
```
## Experimental psychopathology research example {.smaller}

Attentional bias towards negatively valent stimuli is a known feature of depression/anxiety and other comorbid diagnoses.

This is measured in a lab using a dot probe task.

However, an additional component of those with PTSD is a difficulty disengaging attention from the stimuli afterwards.
```

]
== Quasi experimental psychopathology research
<quasi-experimental-psychopathology-research>
Sometimes referred to as "Type II" clinical research @ComerKendall2013

- Type II research can help identify independent variables that exacerbate, or modify the expression of, existing forms of abnormal behavior

- Cannot to answer causal questions about the development of psychopathology due to pre-existence in sample and interaction with so many other variables

  - Diagnosis is a summary of cumulative history but said history cannot be used to infer what caused diagnosis

- If the IV is a clinical intervention, then could examine variables that either prevent or ameliorate psychopathology

#block[
\#\# Quasi experimental research example

#cite(<FelminghamEtAl2010>, form: "prose") recorded fMRI data in both male and female participants with a diagnosis of PTSD.

- Trauma-exposed controls, and non-- trauma-exposed controls while they viewed masked facial expressions of fear.

- Findings indicated that exposure to trauma was associated with enhanced brainstem activity to fear in women, regardless of the presence of PTSD

- However, in men, brainstem activity was associated only with the development of PTSD.

]
== What were the differences between these types of studies?
<what-were-the-differences-between-these-types-of-studies>
- Type I can identify a putative causal variable that was directly manipulable.

  - This could tell us something about how or why psychopathology might develop.

- Type II might to gain a deeper understanding of the processs or experiences.

  - A study could not attempt to explain a causal relationship between the variables.

- Type III and Type IV can only make descriptive statements about the relationships between variables.

  - No processes, explanations or origins.

= Takeaway:
<takeaway>
It is important to understand what you are trying to achieve with your research and what is possible with the research design you choose.

It is also important to consider what type of studies existing research indicates a need for.

= Linking basic research to clinical interventions
<linking-basic-research-to-clinical-interventions>
= What is basic clinical research?
<what-is-basic-clinical-research>
"any type of psychological research investigating processes that are involved in the development and/or maintenance of psychopathology across any level of explanation (e.g., biological, cognitive, behavioral)" @EhringEtAl2022

- Could also be called fundamental or core research

== Why does basic research matter?
<why-does-basic-research-matter>
Information about core psychological processes is essential to:

- clarify how particular psychological disorders develop, are maintained, and ultimately how they may be prevented

- guide treatment development if the psychopathology process of interest can be modeled with sufficient detail

#block[
@ForsythZvolensky2001.

]
== How much are treatments informed by research?
<how-much-are-treatments-informed-by-research>
- Only 23% of treatments showed a very strong link between basic research and the development of the intervention, and further 20% showed a strong link

#block[
@EhringEtAl2022.

]
== Some of the issues with translating clinical psychology research into treatment/intervention
<some-of-the-issues-with-translating-clinical-psychology-research-into-treatmentintervention>
- Lack of stability and replicability of basic research findings

- Lack of basic studies establishing causality before moving to testing complex clinical intervention

- Overly-broad interventions and easy-to-vary theories

- Imbalance between research focused on efficacy compared to research on mediators, mechanisms of change, and moderators

== Lack of stability and replicability of basic research findings
<lack-of-stability-and-replicability-of-basic-research-findings>
Research findings in clinical psychology are not as reliable as assumed, due to:

- Use of unreliable measures
- Underpowered samples
- Publication bias
- Lack of transparency in research practices

== Lack of basic studies establishing causality before moving to testing complex clinical intervention
<lack-of-basic-studies-establishing-causality-before-moving-to-testing-complex-clinical-intervention>
- Targets for intervention are often identified via correlational studies

- Once identified, they are often tested in applied studies using novel or modified interventions

- This misses two important steps:

+ Is the target a #emph[cause] of psychopathology?
+ #emph[How] do we modify interventions to change this target?

#quote(block: true)[
These questions need to be answered through basic research.
]

== Overly-broad interventions and easy-to-vary theories
<overly-broad-interventions-and-easy-to-vary-theories>
- Establishing causality is difficult in psychological research

- Interventions often lack precision in terms of what they are targeting

- Can lack clear theoretical framework of the mechanisms of change and how psychological processes (e.g., attention, perception, memory, emotion) are involved

- Theories are often easy to vary, and can be used to explain almost any outcome

== Imbalance between research focused on efficacy compared to research on mechanisms of change
<imbalance-between-research-focused-on-efficacy-compared-to-research-on-mechanisms-of-change>
- In order to improve treatments, we need to understand #emph[how] and #emph[why] they work, not just #emph[if] they work

- To get a complete understanding of a treatment, we need to understand: Efficacy, Mediators, Mechanisms of change, Moderators

- This requires whole programs of research, not just a single study

== Linking this to the development of your own thesis project…
<linking-this-to-the-development-of-your-own-thesis-project-1>
- Consider whether the existing literature is indicating the need for a process-based account.

- Don't neglect fundamental psychological research that is relevant to your topic/question. This is often where the "mechanisms" of change are examined.

- Try to #emph[focus] your research questions on specific mechanisms or variables that are theoretically relevant, as opposed to being overly broad in your approach.

= Takeaways:
<takeaways>
- Too many clinical studies are focused on efficacy, and not enough on mediators, mechanisms of change.

- Too many efficacy studies are focused on complex interventions, and theories are often "elastic" to explain any outcome.

= Clinical Analogue Studies
<clinical-analogue-studies>
== What are clinical analogue studies?
<what-are-clinical-analogue-studies>
- Clinical analogue studies are studies that use non-clinical samples to study processes related to psychopathology.

  - For example: The role of attention in PTSD
  - Is this a form of attentional bias towards threat stimuli or an inability to disengage from threat stimuli?

- They allow us to study processes related to psychopathology in a controlled environment.

- They allow specific variables to be manipulated to identify mechanisms of change.

== Why use clinical analogue studies? \#1
<why-use-clinical-analogue-studies-1>
- Research with clinical groups is often correlational which does not allow drawing conclusions about what causation.

- The use of experimental designs with clinical population can be ethically problematic, as exposure to stimuli (e.g., stressors) to measure "in the moment" effects, could be traumatic.

- Retrospective reports lack objective information about external stumuli or order of events.

#block[
@EhringEtAl2011

]
== Why use clinical analogue studies? \#2
<why-use-clinical-analogue-studies-2>
- Subclinical measurements can allow accurate modelling of relevant processes (e.g.~Depression: #cite(<HillEtAl1987>, form: "prose");).

- Allows design of studies to better understand the relationship between:

  - treatment -\> process \
  - process -\> outcome

@EhringEtAl2022

- Allows control and focus on specific variables to identify mechanisms of change @EhringEtAl2022

== Intervention -\> process -\> outcome
<intervention---process---outcome>
#box(image("images/moderation.png"))

== Clinical relevance of analogue studies
<clinical-relevance-of-analogue-studies>
- "the nature and intensity of the target problem, not the clinical status of the subjects, are the critical variables in analogue research" (e.g., fear and phobias: #cite(<BorkovecRachman1979>, form: "prose");, p.~253).

- Basic research has helped identify etiological factors in the development of many disorders (e.g.~OCD: #cite(<Gibbs1996>, form: "prose");)

- Symptoms can be prevalent in non-clinical populations, with similar qualitative expressions of experience and similar causal and maintenance factors @AbramowitzEtAl2014[#cite(<AbramowitzEtAl2001>, form: "prose");, #cite(<PuckettEtAl>, form: "prose");]

== Limitations of clinical analogue studies? \#1
<limitations-of-clinical-analogue-studies-1>
Potential issues with clinical analogue studies include:

- Ecological validity: the extent to which the findings of a research study are able to be generalized to real-life settings.

- External validity: the extent to which the findings of a research study are able to be generalized to other people, settings, and times.

- Comorbidity: the presence of one or more additional disorders (or diseases) co-occurring with a primary disorder or disease.

== Limitations of clinical analogue studies? \#2
<limitations-of-clinical-analogue-studies-2>
However, it has been argued that the limitations of clinical analogue studies are often overstated @AbramowitzEtAl2014 and that the weaknesses of clinical analogue studies are often shared with clinical studies (i.e.~poor research is poor research, regardless of the sample):

- Lack of sufficient power in studies
- Reliance on findings from single studies that have yet to be replicated
- Weakness in research designs
- Over-reliance on or misunderstanding of NHST
- Diagnostic unreliability
- Selective reporting of results

= Takeaways:
<takeaways-1>
- Clinical analogue studies are studies are an improtant part of studying processes related to psychopathology.

- They can help us break down the intervention -\> process -\> outcome relationship.

- They need to be well designed and well conducted to be useful.

= Open Science
<open-science>
== What is open and reproducible research?
<what-is-open-and-reproducible-research>
- Reproducible research is the idea that research is published with their hypotheses, research plan, materials, data and software code so that others can try to replicate the results and verify the findings.

- Studies are pre-registered, so that researchers can see if the study was conducted as planned and the results support the researchers' original hypotheses.

== Why Reproducible Research?
<why-reproducible-research>
- One of the major limitations of clinical research can be lack of transparency and reproducibility

- Linked to the "easy to vary" problem

- Linked to the "underpowered" problem

- Linked to the "publication bias" problem

- Linked to the "file drawer" problem

== How does open research help address these problems?
<how-does-open-research-help-address-these-problems>
- Researchers outline their goals and theories before they begin their research, so that they can be held accountable for their results.

- Sample sizes are determined before the study begins, so that the study is adequately powered to detect the effect size of interest.

- Researchers are encouraged to make all of their results available, regardless of whether the results are statistically significant (where possible).

- Materials, data and code are made available, so that others can try to replicate the results and verify the findings.

== How to make your research reproducible?
<how-to-make-your-research-reproducible>
- Pre-register your study

  - #link("https://osf.io/")[Open Science Framework]
  - #link("https://www.crd.york.ac.uk/prospero/")[Prospero]
  - #link("https://aspredicted.org/")[AsPredicted]

- Conduct a power anaysis before you begin your study

  - #link("http://www.gpower.hhu.de/en.html")[G\*Power]
  - #link("https://webpower.psychstat.org/wiki/Main_Page")[Webpower]
  - R, SPSS etc.

- Update your registration with any changes to your study and explain why you made the changes

- After your study has been completed, upload your materials, data and code to a repository

  - #link("https://osf.io/")[Open Science Framework]
  - #link("https://figshare.com/")[Figshare]
  - #link("https://zenodo.org/")[Zenodo]
  - #link("https://datadryad.org/")[Dryad]
  - #link("https://dataverse.org/")[Dataverse]
  - #link("https://dataverse.harvard.edu/")[Harvard Dataverse]
  - #link("https://www.openicpsr.org/openicpsr/")[OpenICPSR]
  - #link("https://openneuro.org/")[OpenNeuro]
  - #link("https://openfmri.org/")[OpenfMRI]

= Takeaways:
<takeaways-2>
- Open research increases the transparency of research

- In doing so, it also helps to address some of the problems in clinical research

== References
<references>


 
  
#set bibliography(style: "apa.csl") 


#bibliography("references.bib")

