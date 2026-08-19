---
layout: home
title: Über uns
description: "Die Band, die Besetzung und das Programm von Wonderbrass."
---

<section class="section section-dark">
  <div class="container text-center">
    <h2 class="section-title d-block mx-auto mb-4" style="width: fit-content;">Die Band</h2>

    <div class="row g-4 justify-content-center mb-5">
      {% for mitglied in site.data.mitglieder %}
        <div class="col-6 col-md-3 text-center">
          <div class="member-avatar mx-auto mb-3">
            {% if mitglied.foto %}
              <img src="{{ '/assets/img/mitglieder/' | append: mitglied.foto | relative_url }}" alt="{{ mitglied.name }}" loading="lazy">
            {% else %}
              <i class="fa-solid fa-user" aria-hidden="true"></i>
            {% endif %}
          </div>
          <p class="member-name mb-0">{{ mitglied.name }}</p>
          <p class="member-instrument mb-0">{{ mitglied.instrument }}</p>
        </div>
      {% endfor %}
    </div>

    <p class="col-lg-8 mx-auto mb-0">
      Sieben Blechbläser, ein Schlagzeuger – und jede Menge Spielfreude. Wonderbrass
      bringt echten Blechsound auf die Bühne, egal ob Festzelt, Kirchenkonzert oder
      Hochzeitsfeier.
    </p>
  </div>
  </section>
  <section class="section bg-tertiary">
  <div class="container text-center mt-4 mt-4">
    <h2 class="section-title d-block mx-auto mb-4" style="width: fit-content;">Programm</h2>

    <div class="row g-3 justify-content-center mt-4 mb-5">
      {% for anlass in site.data.anlaesse %}
        <div class="col-6 col-md-4 col-lg-2 text-center">
          <div class="program-badge mx-auto mb-2">
            <i class="fa-solid {{ anlass.icon }}" aria-hidden="true"></i>
          </div>
          <p class="mb-0 small">{{ anlass.name }}</p>
        </div>
      {% endfor %}
    </div>

    <p class="col-lg-8 mx-auto mb-0">
      <strong>Alles, was Blech ist.</strong> Lasst euch überraschen, wie vielseitig
      und lässig Blasmusik sein kann: Wir machen vor fast nichts halt und
      spielen alles, was sich mit sieben Blechbläsern und einem Schlagzeuger
      spielen lässt – von Polka über klassische Bearbeitungen bis zu Coversongs
      von Mnozil Brass, Rossini und Wagner bis hin zu den Beatles, Queen und Abba.
      Über 60 Stücke umfasst unser Repertoire mittlerweile.
    </p>
  </div>
</section>