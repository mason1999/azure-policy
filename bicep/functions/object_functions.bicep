targetScope = 'managementGroup'

@export()
func create_array_from_object_field(input_object object, old_key string, new_key string) array =>
  contains(input_object, old_key)
    ? (empty(input_object[old_key])
        ? [delete_object_keys(input_object, [old_key])]
        : reduce(
            input_object[old_key],
            [],
            (accumulator, item) =>
              union(accumulator, [delete_object_keys(union(input_object, { '${new_key}': item }), [old_key])])
          ))
    : [input_object]

@export()
func delete_object_keys(input_object object, deletion_keys array) object =>
  reduce(
    filter(objectKeys(input_object), key => !contains(deletion_keys, key)),
    {},
    (accumulator, current_key) =>
      union(accumulator, {
        '${current_key}': input_object[current_key]
      })
  )

@export()
func retain_object_keys(input_object object, retention_keys array) object =>
  reduce(
    filter(objectKeys(input_object), key => contains(retention_keys, key)),
    {},
    (accumulator, current_key) =>
      union(accumulator, {
        '${current_key}': input_object[current_key]
      })
  )

@export()
// We have to explictly return a specific type (like object). This is because you can't return any.
// example: object_get(my_obj, '.a.b.c').value
func object_get(input_object object, path string) object =>
  reduce(
    path == '' || path == '.' ? [] : skip(split(path, '.'), 1),
    { value: input_object },
    (accumulator, path_key) =>
      accumulator.value == null
        ? { value: null }
        : { value: contains(accumulator.value, path_key) ? accumulator.value[path_key] : null } // safe dereference does not work here. Instead the evauluation fails.
  )

@export()
// We have to have our array be of size 1 and strongly types. If not, then it will not be able to compile. This or an object would work.
func object_set(input_object object, path string, value array) object =>
  path == '.' || path == ''
    ? value[0]
    : reduce(
        range(0, length(skip(split(path, '.'), 1))),
        {
          path_array: skip(split(path, '.'), 1)
          output_object: value[0]
        },
        (accumulator, index) =>
          shallowMerge([
            accumulator
            {
              path_array: take(accumulator.path_array, length(accumulator.path_array) - 1)
              output_object: shallowMerge([
                object_get(
                    input_object,
                    concat('.', join(take(accumulator.path_array, length(accumulator.path_array) - 1), '.'))
                  ).value == null
                  ? {}
                  : object_get(
                      input_object,
                      concat('.', join(take(accumulator.path_array, length(accumulator.path_array) - 1), '.'))
                    ).value
                {
                  '${last(accumulator.path_array)}': accumulator.output_object
                }
              ])
            }
          ])
      ).output_object

@export()
func object_del(input_object object, path string) object =>
  reduce(
    [0],
    {
      last_char: last(skip(split(path, '.'), 1))
      prefix_dot_last_char: '.${last(skip(split(path, '.'), 1))}'
      path_to_second_last: concat(
        '.',
        join(take(skip(split(path, '.'), 1), length(skip(split(path, '.'), 1)) - 1), '.')
      )
      output: {}
    },
    (accumulator, dummy) =>
      path == '' || path == '.'
        ? { output: {} }
        : object_get(input_object, accumulator.path_to_second_last).value == null
            ? { output: input_object }
            : shallowMerge([
                accumulator
                {
                  output: object_set(input_object, accumulator.path_to_second_last, [
                    delete_object_keys(
                      object_get(input_object, accumulator.path_to_second_last).value,
                      [accumulator.?last_char]
                    )
                  ])
                }
              ])
  ).output

@export()
func object_update_paths(input_object object, old_path string, new_path string) object =>
  object_set(object_del(input_object, old_path), new_path, [object_get(input_object, old_path).value])
