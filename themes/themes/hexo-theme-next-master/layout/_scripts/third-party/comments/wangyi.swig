{% if theme.wangyi_productKey %}
  {% set wangyi_productKey = theme.wangyi_productKey %}
  {% if page.comments %}
    <script type="text/javascript">
      var cloudTieConfig = {
      url: document.location.href, 
      sourceId: "",
      productKey: "{{wangyi_productKey}}",
      target: "cloud-tie-wrapper"
    };
    </script>    
    <script src="https://img1.cache.netease.com/f2e/tie/yun/sdk/loader.js"></script>
  {% endif %}
{% endif %}
