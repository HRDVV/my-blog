{% extends '_layout.swig' %}
{% import '_macro/post-collapse.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}{{ __('title.tag') }}: {{ page.tag }} | {{ title }}{% endblock %}

{% block content %}

  {#################}
  {### TAG BLOCK ###}
  {#################}
  <div class="post-block tag">
    <div class="tag-cloud">
      <div class="tag-cloud-title">
        {% set visibleTags = 0 %}
        {% for tag in site.tags %}
          {% if tag.length %}
            {% set visibleTags += 1 %}
          {% endif %}
        {% endfor %}
        {{ _p('counter.tag_cloud', visibleTags) }}
      </div>
      <div class="tag-cloud-tags">
        {% if not theme.tagcloud %}
          {{ tagcloud({min_font: 12, max_font: 30, amount: 200, color: true, start_color: '#ccc', end_color: '#111'}) }}
        {% else %}
          {{ tagcloud({min_font: theme.tagcloud.min, max_font: theme.tagcloud.max, amount: theme.tagcloud.amount, color: true, start_color: theme.tagcloud.start, end_color: theme.tagcloud.end}) }}
        {% endif %}
      </div>
    </div>

    <div id="posts" class="posts-collapse">
      {% for post in page.posts %}
        {{ post_template.render(post) }}
      {% endfor %}
    </div>

  </div>
  {#####################}
  {### END TAG BLOCK ###}
  {#####################}

  {% include '_partials/pagination.swig' %}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
