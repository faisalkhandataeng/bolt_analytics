{% test non_negative(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0

{% endtest %}

{% test valid_time_order(model, start_column, end_column) %}

select *
from {{ model }}
where {{ end_column }} < {{ start_column }}

{% endtest %}

{% test percentage_between_zero_and_one(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0
   or {{ column_name }} > 1

{% endtest %}

